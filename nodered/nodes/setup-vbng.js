var net=require("net");
var exec=require("child_process").exec;

var ScriptPath = "/home/foundry/vbng/";
var InsideInterfaceSouthName="eth1";
var InsideInterfaceNorthName="eth2";
var InsideScriptPath = "/root/";

/*

{
  "Hostname": "vbng-02",
  "Template": "bng-template-v2",
  "SrIovInterface": "p1p1_0",
  "SouthIpSubnet": "10.20.1.2/24",
  "SouthGateway": "10.20.1.1",
  "VxlanLoopback": "10.50.1.2",
  "VxlanVni": "5002",
  "VxlanEndpoint": "10.50.1.1",
  "HostedGateway": "20.20.0.1",
  "NorthIpSubnet": "10.30.1.2/24",
  "NorthGateway": "10.30.1.1",
  "PoliceRate": "4000mbit"
}

*/


module.exports = function(RED) {
  
    function SetupVbngNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);

        var node = this;
        node.Hostname=config.Hostname;
        node.SouthIpSubnet=config.SouthIpSubnet;
        node.SouthGateway=config.SouthGateway;
        node.VxlanLoopback=config.VxlanLoopback;
        node.VxlanVni=config.VxlanVni;
        node.VxlanEndpoint=config.VxlanEndpoint;
        node.HostedGateway=config.HostedGateway;
        node.NorthIpSubnet=config.NorthIpSubnet;
        node.NorthGateway=config.NorthGateway;
        node.PoliceRate=config.PoliceRate;

        this.on('input', function(msg) {
	    var Hostname; 
	    var SouthIpSubnet;
	    var SouthGateway;
            var VxlanLoopback;
	    var VxlanVni;
	    var VxlanEndpoint;
	    var HostedGateway;
	    var NorthIpSubnet;
	    var NorthGateway;
	    var PoliceRate;

	    if(msg.payload.Hostname==null){
	       Hostname=node.Hostname;
	    }else{
	       Hostname=msg.payload.Hostname;
	    }

	    if(msg.payload.SouthIpSubnet==null){
	       SouthIpSubnet=node.SouthIpSubnet;
	    }else{
               SouthIpSubnet=msg.payload.SouthIpSubnet;
	    }

	    if(msg.payload.SouthGateway==null){
	       SouthGateway=node.SouthGateway;
	    }else{
               SouthGateway=msg.payload.SouthGateway;
	    }

	    if(msg.payload.VxlanLoopback==null){
	       VxlanLoopback=node.VxlanLoopback;
	    }else{
               VxlanLoopback=msg.payload.VxlanLoopback;
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

	    if(msg.payload.NorthIpSubnet==null){
	       NorthIpSubnet=node.NorthIpSubnet;
	    }else{
               NorthIpSubnet=msg.payload.NorthIpSubnet;
	    }

	    if(msg.payload.NorthGateway==null){
	       NorthGateway=node.NorthGateway;
	    }else{
               NorthGateway=msg.payload.NorthGateway;
	    }

	    if(msg.payload.PoliceRate==null){
	       PoliceRate=node.PoliceRate;
	    }else{
               PoliceRate=msg.payload.PoliceRate;
	    }

            if (msg.payload.Status==null){
               msg.payload.Status = "";
            }

            var command="cp -a "+ScriptPath+"/* /var/lib/lxc/"+Hostname+"/rootfs/"+InsideScriptPath;
            console.log(command);

            var logprefix = "vBNG Container "+Hostname+" setup";
            exec(command,(error,stdout,stderr)=>{
                 if(stderr!=""){
                    msg.payload.Status += "FAILED:"+logprefix+":"+stderr+".";
                    node.error(msg.payload.Status, msg);
                 }else{
                    msg.payload.Status += "SUCCESS:"+command+":"+stdout+".";
                    console.log(msg.payload.Status);

                    //   vbng-setup2.sh eth1 10.20.2.2/24 10.20.2.1 10.50.1.2 5002 10.50.1.1 20.20.0.1 eth2 10.30.1.2/24 2.2.0.0/16 10.30.1.1 10000mbit
                    command="lxc-attach -n "+Hostname+" -- bash "+InsideScriptPath+"/vbng-setup2.sh "+InsideInterfaceSouthName+" "+SouthIpSubnet+" "+SouthGateway+" "+VxlanLoopback+" "+VxlanVni+" "+VxlanEndpoint+" "+HostedGateway+" "+InsideInterfaceNorthName+" "+NorthIpSubnet+" "+NorthGateway+" "+PoliceRate;
                    console.log(command);
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
                 }
            });

        });
    }

    RED.nodes.registerType("setup-vbng",SetupVbngNode);
}

