import ether_ip

print(ether_ip.get_string('V[1].Interface_Desc0', '172.23.243.77').decode())
print(ether_ip.get_int('PLC_Interface[23].Num', '172.23.243.77'))
print(ether_ip.get_double('V[1].Position', '172.23.243.77'))
