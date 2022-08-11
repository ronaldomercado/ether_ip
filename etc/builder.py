from iocbuilder import AutoSubstitution, Substitution, ModuleBase
from iocbuilder import Device
from iocbuilder.arginfo import *

class EtherIPInit(Substitution, Device):
    """This creates an IP connection to a plc using the ether_ip driver"""
    # Dependencies = ()
    LibFileList = ['ether_ip']
    DbdFileList = ['ether_ip']
    AutoInstantiate = True
    
    def __init__(self, name, device, port, ip, PLCinfo=True):
        self.device = device
        self.port = port
        self.ip = ip
        if (PLCinfo):
            # Fill in the template with these arguments
            self.template = _PLCinfo(name=name, device=device, port=port)

    def InitialiseOnce(self):
        print "# EtherIP Initialisation"
        print "drvEtherIP_init()"

    def Initialise(self):
        print "# Define EtherIP to PLC connection"
        print "drvEtherIP_define_PLC(\"{0}\", \"{1}\", 0)".format(self.port, self.ip)
        
    ArgInfo = makeArgInfo(__init__,  
        name=Simple("Name"),  
        device = Simple("PV Prefix"),
        port = Simple("Port Name"),
        ip = Simple("IP Port of PLC"),
        PLCinfo = Simple ("Add PLC information PVs -- do only once per device", bool)
    )

class bo(AutoSubstitution):
    TemplateFile = "ether_ip_bo.template"

class bi(AutoSubstitution):
    TemplateFile = "ether_ip_bi.template"

class ao(AutoSubstitution):
    TemplateFile = "ether_ip_ao.template"

class ai(AutoSubstitution):
    TemplateFile = "ether_ip_ai.template"

class stringin(AutoSubstitution):
    TemplateFile = "ether_ip_stringin.template"

class mbboDirect(AutoSubstitution):
    TemplateFile = "ether_ip_mbboDirect.template"

class mbbiDirect(AutoSubstitution):
    TemplateFile = "ether_ip_mbbiDirect.template"

class _PLCinfo(AutoSubstitution):
    ''' Template file with simple PVs collecting PLC information '''
    TemplateFile = "ether_ip_plcInfo.template"
