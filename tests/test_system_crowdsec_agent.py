import unittest

from tests.software_global_contract import SoftwareGlobalContract


class CrowdsecGlobalTests(SoftwareGlobalContract, unittest.TestCase):
    software = 'crowdsec-agent'
