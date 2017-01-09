var net=require("net");
var exec=require("child_process").exec;

var ScriptPath = "/home/foundry/vbng/";
var InsideInterfaceName="eth1";
var InsideScriptPath = "/root/";


module.exports = function(RED) {
  
    function DestroyVbngNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);

        var node = this;
        node.Hostname=config.Hostname;
        node.IpSubnet=config.IpSubnet;
        node.VxlanVni=config.VxlanVni;
        node.VxlanEndpoint=config.VxlanEndpoint;
        node.HostedGateway=config.HostedGateway;
        node.Route=config.Route;
        node.NextHop=config.NextHop;
        node.PoliceRate=config.PoliceRate;

        this.on('input', function(msg) {
	    var Hostname; 
	    var IpSubnet;
	    var VxlanVni;
	    var VxlanEndpoint;
	    var HostedGateway;
	    var Route;
	    var NextHop;
	    var PoliceRate;

	    if(msg.payload.Hostname==null){
	       Hostname=node.Hostname;
	    }else{
	       Hostname=msg.payload.Hostname;
	    }

	    if(msg.payload.IpSubnet==null){
	       IpSubnet=node.IpSubnet;
	    }else{
               IpSubnet=msg.payload.IpSubnet;
	    }

	    if(msg.payload.VxlanVni==null){
	       VxlanVni=node.VxlanVni;
	    }else{
               VxlanVni=msg.payload.VxlanVni;
	    }

	    if(msg.payload.VxlanEndpoint==null){
	       VxlanEndpoint=node.VxlanEndpoint;
	    }else{
               VxlanEndpoint=msg.payload.VxlanEndpoint;
	    }

	    if(msg.payload.HostedGateway==null){
	       HostedGateway=node.HostedGateway;
	    }else{
               HostedGateway=msg.payload.HostedGateway;
	    }

	    if(msg.payload.Route==null){
	       Route=node.Route;
	    }else{
               Route=msg.payload.Route;
	    }

	    if(msg.payload.NextHop==null){
	       NextHop=node.NextHop;
	    }else{
               NextHop=msg.payload.NextHop;
	    }

	    if(msg.payload.PoliceRate==null){
	       PoliceRate=node.PoliceRate;
	    }else{
               PoliceRate=msg.payload.PoliceRate;
	    }


            if (msg.payload.Status==null){
               msg.payload.Status = "";
            }

            var command="lxc-attach -n "+Hostname+" -- bash "+InsideScriptPath+"/vbng-destroy.sh "+InsideInterfaceName+" "+IpSubnet+" "+VxlanVni+" "+VxlanEndpoint+" "+HostedGateway+" "+Route+" "+NextHop+" "+PoliceRate+" 2>&1";
            console.log(command);

            var logprefix = "vBNG Container "+Hostname+" de-configured";
            exec(command,(error,stdout,stderr)=>{
                 if(stderr!=""){
                    msg.payload.Status += "FAILED:"+logprefix+":"+stderr+".";
                    node.error(msg.payload.Status, msg);
                 }else{
                    msg.payload.Status += "SUCCESS:"+logprefix+":"+stdout+".";
                    console.log(msg.payload.Status);
                    node.send(msg);
                 }
            });

        });
    }

    RED.nodes.registerType("destroy-vbng",DestroyVbngNode);
}

