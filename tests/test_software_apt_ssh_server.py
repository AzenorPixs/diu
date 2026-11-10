import unittest

from tests.software_global_contract import SoftwareGlobalContract


class SoftwareAptGlobalTests(SoftwareGlobalContract, unittest.TestCase):
    software = 'ssh-server'
