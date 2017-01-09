var bridge="access";
var exec=require("child_process").exec;

module.exports = function(RED) {
  
    function DelVlanNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);
        var node = this;
        node.ip=config.ip;
        node.vlan=config.vlan;
        this.on('input', function(msg) {
	    var vlan,container,url;

	    if(msg.payload.vlan==null) vlan=node.vlan;
	    else vlan=msg.payload.vlan;
            
            if(msg.payload.container==null) container=node.container;
            else container=msg.payload.container;
            
            if(msg.payload.url==null) url=node.url;
            else url=msg.payload.url;
            
            msg.url=url;
      

            var vlanValid=!isNaN(vlan)&&vlan>1&&vlan<4096;
            
            if(vlanValid){

            }else{
               var error="ERROR:<br>\n";
               if(!ipValid){
                  error+=ip + " is not a valid ip delress<br>\n";
               }
               if(!vlanValid){
                  error+=vlan+ " is not a valid vlan<br>\n";
               }
               msg.payload.error=error;
               sendStatus(url,msg.payload,error,node);
               return;
            }
            var iFace=bridge+"."+vlan;

            var command="lxc-attach -n "+container+" -- ip link del "+iFace;
            console.log(command);
            exec(command,(error,stdout,stderr)=>{
                 if(stderr!=""){
                       console.log(stderr);
		       sendStatus(url,msg.payload,stderr,node);
		       return;
                 }else{
                    sendStatus(url,msg.payload,"interface deleted",node);
                 }
            });
            node.send(msg,null,null); 
        });
    }
    RED.nodes.registerType("del-vlan",DelVlanNode);
}

function sendStatus(url,payload,status,node){
   var newMsg=new Object();
   newMsg.url=url;
   newMsg.payload=payload;
   newMsg.payload.status=status;
   node.send([null,null,newMsg]);
}
