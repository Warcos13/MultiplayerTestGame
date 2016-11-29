#define client_connect
///client_connect(ip,port,name);

var
ip = argument0,
port = argument1,
name = argument2;

socket = network_create_socket(network_socket_tcp);
var connect = network_connect_raw(socket, ip, port);

send_buffer = buffer_create(256,buffer_fixed,1);

clientmap = ds_map_create();

if(connect<0) show_error("Could not connect to server!",true);

buffer_seek(send_buffer, buffer_seek_start,0);
buffer_write(send_buffer,buffer_u8,MESSAGE_JOIN);
buffer_write(send_buffer,buffer_string,name);
network_send_raw(socket,send_buffer,buffer_tell(send_buffer));

my_clien_id=-1;



#define client_disconnect
///client_disconnetc()

ds_map_destroy(clientmap);
network_destroy(socket);

#define client_handle_message
///client_handle_message(buffer)

var
buffer = argument0;

while(true){
    var
    message_id = buffer_read(buffer,buffer_u8);
    
    switch(message_id){
            
        case MESSAGE_GETID:
            my_client_id = buffer_read(buffer,buffer_u16);
        
        break;   
    
        case MESSAGE_MOVE:
            var
            client = buffer_read(buffer, buffer_u16);
            xx = buffer_read(buffer, buffer_u16);
            yy = buffer_read(buffer, buffer_u16);
            dir = buffer_read(buffer, buffer_u16);
                        
            clientObject = client_get_object(client);
            
           /* clientObject.tim = 0;
            clientObject.prx = clientObject.x;
            clientObject.pry = clientObject.y;            
            clientObject.tox = xx;
            clientObject.toy = yy;*/
            
            clientObject.x = xx;
            clientObject.y = yy;    
            clientObject.image_angle = dir;
        break;
        
        case MESSAGE_JOIN:
            var
            client = buffer_read(buffer, buffer_u16),
            username = buffer_read(buffer,buffer_string);
            clientObject = client_get_object(client);
            clientObject.name = username;
            
        break;
        case MESSAGE_LEAVE:
            var
            client = buffer_read(buffer,buffer_u16);
            tempObject = client_get_object(client);
            with(tempObject){
                instance_destroy();
            }       
        break;
        
        case MESSAGE_KILL:            
            var 
            clientshootid = buffer_read(buffer, buffer_u16),
            clientshoot = client_get_object(clientshootid),
            clientshotid = buffer_read(buffer, buffer_u16),
            clientshot = client_get_object(clientshotid),
            shootdirection = buffer_read(buffer, buffer_u16),
            shootlength = buffer_read(buffer, buffer_u16);
            hit_x = clamp(clientshoot.x + lengthdir_x(shootlength,shootdirection),clientshot.x,clientshot.x+16);
            hit_y = clamp(clientshoot.y + lengthdir_y(shootlength,shootdirection),clientshot.y,clientshot.y+16);
            create_shoot_line(clientshoot.x,clientshoot.y, hit_x, hit_y);
            with(clientshot){
                do{
                    randomize();
                    x = random(room_width);
                    y = random(room_height); 
                    with(clientshot){
                        collision = place_meeting(x,y,obj_wall);
                    }        
                }
                until clientshot.collision=0;     
            }
            clientshot.hp = buffer_read(buffer, buffer_u8);
        break;
        case MESSAGE_HIT:            
            var    
            clientshootid = buffer_read(buffer, buffer_u16),
            clientshoot = client_get_object(clientshootid),
            clientshotid = buffer_read(buffer, buffer_u16),
            clientshot = client_get_object(clientshotid),
            shootdirection = buffer_read(buffer, buffer_u16),
            shootlength = buffer_read(buffer, buffer_u16);
            hit_x = clamp(clientshoot.x + lengthdir_x(shootlength,shootdirection),clientshot.x,clientshot.x+16);
            hit_y = clamp(clientshoot.y + lengthdir_y(shootlength,shootdirection),clientshot.y,clientshot.y+16);
            create_shoot_line(clientshoot.x,clientshoot.y, hit_x, hit_y);
            clientshot.hp = buffer_read(buffer, buffer_u8);
        break;
         case MESSAGE_HIT_WALL:            
            var    
            clientshootid = buffer_read(buffer, buffer_u16),
            clientshoot = client_get_object(clientshootid),
            shootdirection = buffer_read(buffer, buffer_u16),
            shootlength = buffer_read(buffer, buffer_u16);
            target_x = buffer_read(buffer, buffer_u16);
            target_y = buffer_read(buffer, buffer_u16);
            
            hit_x = clamp(clientshoot.x + lengthdir_x(shootlength,shootdirection),target_x,target_x+16);
            hit_y = clamp(clientshoot.y + lengthdir_y(shootlength,shootdirection),target_y,target_y+16);
            create_shoot_line(clientshoot.x,clientshoot.y, hit_x, hit_y)
        break;
        case MESSAGE_MISS:
            var    
            clientshootid = buffer_read(buffer, buffer_u16),
            clientshoot = client_get_object(clientshootid),
            shootdirection = buffer_read(buffer, buffer_u16),
            shootlength = buffer_read(buffer, buffer_u16);
            create_shoot_line(clientshoot.x,clientshoot.y,clientshoot.x + lengthdir_x(shootlength,shootdirection),
            clientshoot.y + lengthdir_y(shootlength,shootdirection) );
        break;
    }
    
    if(buffer_tell(buffer) == buffer_get_size(buffer)){
        break;   
    }
}

#define client_send_movement
///client_send_movement()

buffer_seek(send_buffer,buffer_seek_start,0);
buffer_write(send_buffer,buffer_u8,MESSAGE_MOVE);
buffer_write(send_buffer,buffer_u16,round(obj_player.x));
buffer_write(send_buffer,buffer_u16,round(obj_player.y));
buffer_write(send_buffer,buffer_u16,round(obj_player.image_angle));
network_send_raw(socket,send_buffer,buffer_tell(send_buffer));

#define client_get_object
///client_get_object(client_id)
var
client_id = argument0;
if(client_id ==my_client_id){
    if(!instance_exists(obj_player))
        instance_create(0,0,obj_player);
        
        
    return obj_player.id;
}
// if recive message from this client before
if(ds_map_exists(clientmap,string(client_id))){
    return clientmap[? string(client_id)];
}else{
    var l = instance_create(0,0,obj_otherClient);
    clientmap[? string(client_id)] = l;
    return l;
}

#define client_send_shoot
///client_send_shoot(direnction,dmg)

var 
dir = argument0,
dmg = argument1;
buffer_seek(send_buffer,buffer_seek_start,0);

buffer_write(send_buffer, buffer_u8,MESSAGE_SHOOT);
buffer_write(send_buffer, buffer_u16,dir);
buffer_write(send_buffer, buffer_u8,dmg);

network_send_raw(socket, send_buffer, buffer_tell(send_buffer));
