#!/usr/bin/env python3
"""Publish a small group of managed configuration files with rollback."""

import os

from ssh_configuration import read_regular, unchanged, write_candidate


def publish(changes, validate=None):
    records = []
    try:
        for path, original, metadata, updated, mode in changes:
            if updated is None and metadata is None:
                continue
            if updated == original and metadata is not None and (mode is None or metadata.st_mode & 0o777 == mode):
                continue
            record = {"path": path, "original": original, "metadata": metadata, "updated": updated,
                      "candidate": None, "rollback": None, "published": None,
                      "committed": False, "preserve": False}
            records.append(record)
            if updated is not None:
                record["candidate"] = write_candidate(path, updated, metadata, forced_mode=mode)
            if metadata is not None:
                record["rollback"] = write_candidate(path, original, metadata, forced_mode=mode)
        if any(not unchanged(item["path"], item["original"], item["metadata"]) for item in records):
            raise ValueError("configuration modifiée simultanément")
        try:
            for item in records:
                if item["updated"] is None:
                    item["path"].unlink()
                elif item["metadata"] is None:
                    os.link(item["candidate"], item["path"])
                else:
                    os.replace(item["candidate"], item["path"])
                    item["candidate"] = None
                item["committed"] = True
                if item["updated"] is not None:
                    _, item["published"] = read_regular(item["path"])
            if validate:
                validate()
        except BaseException as error:
            failures = []
            for item in reversed(records):
                if not item["committed"]:
                    continue
                try:
                    current, metadata = read_regular(item["path"], missing=True)
                    published = item["published"]
                    if item["updated"] is None:
                        if metadata is not None:
                            raise ValueError("fichier recréé simultanément")
                    elif (metadata is None or current != item["updated"] or published is None or
                          (metadata.st_dev, metadata.st_ino, metadata.st_mode, metadata.st_uid, metadata.st_gid) !=
                          (published.st_dev, published.st_ino, published.st_mode, published.st_uid, published.st_gid)):
                        raise ValueError("fichier modifié simultanément")
                    if item["rollback"]:
                        os.replace(item["rollback"], item["path"])
                        item["rollback"] = None
                    elif metadata is not None:
                        item["path"].unlink()
                except (OSError, ValueError):
                    item["preserve"] = True
                    failures.append(str(item["rollback"] or item["path"]))
            if failures:
                raise ValueError("configuration partielle ; éléments conservés : " + ", ".join(failures)) from error
            raise
    finally:
        for item in records:
            if item["candidate"]:
                item["candidate"].unlink(missing_ok=True)
            if item["rollback"] and not item["preserve"]:
                item["rollback"].unlink(missing_ok=True)
