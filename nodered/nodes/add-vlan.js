var net=require("net");
var bridge="access";
var ingress="0:1 1:2 2:3 3:4 4:5 5:6 6:7 7:8";
var egress="1:0 2:1 3:2 4:3 5:4 6:5 7:6 8:7";
var exec=require("child_process").exec;

module.exports = function(RED) {
  
    function AddVlanNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);
        var node = this;
        node.ip=config.ip;
        node.vlan=config.vlan;
        this.on('input', function(msg) {
	    var vlan,ip,container,url,gateway;

	    if(msg.payload.vlan==null) vlan=node.vlan;
	    else vlan=msg.payload.vlan;
	    
            if(msg.payload.ip==null) ip=node.ip;
	    else ip=msg.payload.ip;
	    
            if(msg.payload.container==null) container=node.container;
            else container=msg.payload.container;
            
            if(msg.payload.url==null) url=node.url;
            else url=msg.payload.url;
            
            if(msg.payload.gateway==null) gateway=node.gateway;
            else gateway=msg.payload.gateway;
            
            msg.url=url;
      
            var ipType=net.isIP(ip);
            var ipValid=ipType!=0;

            var vlanValid=!isNaN(vlan)&&vlan>1&&vlan<4096;
            
            if(vlanValid&&ipValid){

            }else{
               var error="ERROR:<br>\n";
               if(!ipValid){
                  error+=ip + " is not a valid ip address<br>\n";
               }
               if(!vlanValid){
                  error+=vlan+ " is not a valid vlan<br>\n";
               }
               msg.payload.error=error;
               sendStatus(url,msg.payload,error,node);
               return;
            }
            var iFace=bridge+"."+vlan;

            var command="lxc-attach -n "+container+" -- ip link add link "+bridge+" "+iFace+" type vlan id "+vlan+" ingress-qos-map "+ingress+" egress-qos-map "+egress;
            console.log(command);
            exec(command,(error,stdout,stderr)=>{
                 if(stderr!=""){
                       console.log(stderr);
		       sendStatus(url,msg.payload,stderr,node);
		       return;
                 }else{
                    sendStatus(url,msg.payload,"interface created",node);
                     command="lxc-attach -n "+container+" ip link set "+iFace+" up";
                     console.log(command);
                     exec(command,(error,stdout,stderr)=>{
                          if(stderr!=""){
                               console.log(stderr);
			       sendStatus(url,msg.payload,stderr,node);
			       return;
                          }else{
                             sendStatus(url,msg.payload,"interface brought up",node);
                              command="lxc-attach -n "+container+" -- ip address add "+gateway+"/32 dev "+iFace;
                              console.log(command);
                              exec(command,(error,stdout,stderr)=>{
                                   if(stderr!=""){
                                       console.log(stderr);
				       sendStatus(url,msg.payload,stderr,node);
				       return;
                                   }else{
                                       sendStatus(url,msg.payload,"ip address set",node);
                                       command="lxc-attach -n "+container+" -- ip route add "+ip+"/32 dev "+iFace+" src "+gateway;
                                       console.log(command);
                                       exec(command,(error,stdout,stderr)=>{
                                            if(stderr!=""){
                                               console.log(stderr);
					       sendStatus(url,msg.payload,stderr,node);
					       return;
                                            }else{
                                               sendStatus(url,msg.payload,"route added",node);
                                               node.send([null,msg,null]);
                                               command="lxc-attach -n "+container+" -- /root/shaper.sh " +iFace +" 1mbit"
					       console.log(command);
					       exec(command,(error,stdout,stderr)=>{
					            if(stderr!=""){
						     console.log(stderr);
						     sendStatus(url,msg.payload,stderr,node);
						     return;
                                                    }else{
                                                       sendStatus(url,msg.payload,"ip address set",node);
                                                    }
                                                 });
                                            }
                                       });
                                   }
                              });
                          }
                     });
                 }
            });
            node.send(msg,null,null); 
        });
    }
    RED.nodes.registerType("add-vlan",AddVlanNode);
}

function sendStatus(url,payload,status,node){
   var newMsg=new Object();
   newMsg.url=url;
   newMsg.payload=payload;
   newMsg.payload.status=status;
   node.send([null,null,newMsg]);
}
