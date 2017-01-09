var net=require("net");
var exec=require("child_process").exec;

module.exports = function(RED) {
  
    function ContainerNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);

        var node = this;
        node.Hostname=config.Hostname;
        node.Action=config.Action;

        this.on('input', function(msg) {
	    var Hostname; 
            var Action;

	    if(msg.payload.Hostname==null){
	       Hostname=node.Hostname;
	    }else{
	       Hostname=msg.payload.Hostname;
	    }

	    if(msg.payload.Action==null){
	       Action=node.Action;
	    }else{
	       Action=msg.payload.Action;
	    }

            if (msg.payload.Status==null){
               msg.payload.Status = "";
            }

            var command="";

            if (Action == "start") {
              command = "lxc-start -n "+Hostname;
            } else if (Action == "stop") {
              command = "lxc-stop -n "+Hostname;
            } else if (Action == "destroy") {
              command = "lxc-destroy -n "+Hostname;
            } else {
              node.error("No action passed", msg);
              return;
            }

            console.log(command);

            var logprefix = "Container "+Hostname+" "+Action;
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

    RED.nodes.registerType("container",ContainerNode);
}

