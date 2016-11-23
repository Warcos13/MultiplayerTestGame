#define server_create
///Server Create

var 
port = argument0,
server = 0;

server = network_create_server_raw(network_socket_tcp, port, 20);

clientmap = ds_map_create();
client_id_counter = 0;

send_buffer = buffer_create(256,buffer_fixed,1);

if(server<0){
    show_error("Could not create server!",true);
}

return server;


#define server_handle_connect
///server_handle_connect(socket_id)}

var socket_id = argument0;

l = instance_create(0, 0, obj_serverClient);
l.socket_id = socket_id;
l.client_id = client_id_counter++;
show_debug_message("Client ID: "+string(l.client_id));

show_debug_message("Counter ID: "+string(client_id_counter));
if(client_id_counter>=65000){
    client_id_counter = 0;
}

clientmap[? string(socket_id)] = l;

#define server_handle_message
///server_handle_message(socket_id,buffer);

var 
socket_id = argument0,
buffer = argument1,
client_id_current= clientmap[? string(socket_id)].client_id;

while(true){
    var
    message_id = buffer_read(buffer,buffer_u8);
    
    switch(message_id){
    
        case MESSAGE_MOVE:
        
            var
            xx = buffer_read(buffer,buffer_u16);        
            yy = buffer_read(buffer,buffer_u16);
            
            buffer_seek(send_buffer,buffer_seek_start,0);
            buffer_write(send_buffer, buffer_u8,MESSAGE_MOVE);
            buffer_write(send_buffer, buffer_u16,client_id_current);
            buffer_write(send_buffer, buffer_u16,xx);
            buffer_write(send_buffer, buffer_u16,yy);
            
            with(obj_serverClient){
                if(client_id != client_id_current){
                    network_send_raw(self.socket_id,other.send_buffer,buffer_tell(other.send_buffer));                
                }
            }
        
        break;
    }
    
    if(buffer_tell(buffer) == buffer_get_size(buffer)){
        break;   
    }
}

#define server_handle_disconnect
///server_handle_disconnect(socket_id)

var socket_id = argument0;

with(clientmap[? (string(socket_id))]){
instance_destroy();
    
}

ds_map_delete(clientmap,string(socket_id));