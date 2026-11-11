#!/usr/bin/env python3
"""Maintain a small managed Zsh block without replacing existing user content."""

import os
import sys
from pathlib import Path

from ssh_configuration import read_regular, unchanged, write_candidate


BEGIN = "# BEGIN DIU ZSH CONVERGENCE"
END = "# END DIU ZSH CONVERGENCE"
BLOCK = "\n".join((
    BEGIN,
    '[[ ! -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] || source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh',
    '[[ ! -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] || source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh',
    END,
    "",
))


def without_managed_block(text):
    output = []
    inside = False
    seen = False
    for line in text.splitlines(keepends=True):
        marker = line.rstrip("\r\n")
        if marker == BEGIN:
            if inside or seen:
                raise ValueError("bloc Zsh dupliqué")
            inside = True
            seen = True
        elif marker == END:
            if not inside:
                raise ValueError("bloc Zsh incomplet")
            inside = False
        elif not inside:
            output.append(line)
    if inside:
        raise ValueError("bloc Zsh incomplet")
    return "".join(output)


def configuration_path(prefix):
    root = prefix / "root"
    if root.is_symlink() or not root.is_dir():
        raise ValueError("répertoire root indisponible ou symbolique")
    return root / ".zshrc"


def managed_block(defaults=""):
    if BEGIN in defaults or END in defaults:
        raise ValueError("marqueur réservé dans les réglages Zsh")
    return BLOCK.replace(END, defaults.rstrip() + "\n" + END) if defaults else BLOCK


def configure(prefix, defaults=""):
    path = configuration_path(prefix)
    original, metadata = read_regular(path, missing=True)
    remaining = without_managed_block(original.decode("utf-8"))
    if remaining and not remaining.endswith("\n"):
        remaining += "\n"
    updated = (remaining + managed_block(defaults)).encode("utf-8")
    if updated == original:
        return
    candidate = write_candidate(path, updated, metadata)
    try:
        if not unchanged(path, original, metadata):
            raise ValueError("configuration Zsh modifiée simultanément")
        if metadata is None:
            os.link(candidate, path)
        else:
            os.replace(candidate, path)
            candidate = None
    finally:
        if candidate:
            candidate.unlink(missing_ok=True)


def check(prefix, defaults=""):
    path = configuration_path(prefix)
    original, metadata = read_regular(path, missing=True)
    if metadata is None:
        return 1
    text = original.decode("utf-8")
    without_managed_block(text)
    return 0 if text.count(managed_block(defaults)) == 1 else 1


def main():
    if len(sys.argv) not in (2, 3) or sys.argv[1] not in ("configure", "check", "configure-defaults", "check-defaults"):
        print("Usage : zsh_configuration.py <configure|check> [racine]", file=sys.stderr)
        return 2
    prefix = Path(sys.argv[2]) if len(sys.argv) == 3 else Path("/")
    try:
        defaults = sys.stdin.read(1048577) if sys.argv[1].endswith("-defaults") else ""
        if len(defaults) > 1048576:
            raise ValueError("réglages Zsh trop volumineux")
        if sys.argv[1].startswith("check"):
            return check(prefix, defaults)
        configure(prefix, defaults)
        return 0
    except (OSError, UnicodeError, ValueError) as error:
        detail = str(error) if isinstance(error, ValueError) else "lecture ou écriture impossible"
        print(f"Configuration Zsh incomplète ou impossible : {detail}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
