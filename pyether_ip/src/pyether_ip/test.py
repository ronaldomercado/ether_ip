from . import client

print(client.get_string('V[1].Interface_Desc0', '172.23.243.77'))
print(client.get_int('PLC_Interface[23].Num', '172.23.243.77'))
print(client.get_double('V[1].Position', '172.23.243.77'))

#raise exception
print(client.get_int('V[1].Interface_Desc0', '172.23.243.77'))

#done
print("done")
