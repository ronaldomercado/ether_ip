from iocbuilder import AutoSubstitution, Substitution, ModuleBase
from iocbuilder import Device
from iocbuilder.arginfo import *

class EtherIPInit(Device):
    """This creates an IP connection to a plc using the ether_ip driver"""
    # Dependencies = ()
    LibFileList = ['ether_ip']
    DbdFileList = ['ether_ip']
    AutoInstantiate = True
    
    def __init__(self, name, ip):
        self.__super.__init__()
        self.name = name
        self.ip = ip

    def InitialiseOnce(self):
        print "# EtherIP Initialisation"
        print "drvEtherIP_init()"


    def Initialise(self):
        print "# Define EtherIP to PLC connection"
        print "drvEtherIP_define_PLC(\"{0}\", \"{1}\", 0)".format(self.name, self.ip)
        
    ArgInfo = makeArgInfo(__init__,    
        name = Simple("Port Name"),
        ip = Simple("IP Port of PLC"))

class bo(AutoSubstitution):
    TemplateFile = "bo.template"

class bi(AutoSubstitution):
    TemplateFile = "bi.template"

class ao(AutoSubstitution):
    TemplateFile = "ao.template"

class ai(AutoSubstitution):
    TemplateFile = "ai.template"

class stringin(AutoSubstitution):
    TemplateFile = "stringin.template"

class mbboDirect(AutoSubstitution):
    TemplateFile = "mbboDirect.template"

class mbbiDirect(AutoSubstitution):
    TemplateFile = "mbbiDirect.template"
