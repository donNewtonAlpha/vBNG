var net=require("net");
var exec=require("child_process").exec;

module.exports = function(RED) {
  
    function InitContainerNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);

        var node = this;
        node.Hostname=config.Hostname;
        node.Template=config.Template;

        this.on('input', function(msg) {
	    var Hostname; 
	    var Template;

	    if(msg.payload.Hostname==null){
	       Hostname=node.Hostname;
	    }else{
	       Hostname=msg.payload.Hostname;
	    }

	    if(msg.payload.Template==null){
	       Template=node.Template;
	    }else{
               Template=msg.payload.Template;
	    }

            if (msg.payload.Status==null){
               msg.payload.Status = "";
            }

            var command="lxc-copy -n "+Template+" -N "+Hostname;
            console.log(command);

            var logprefix = "Container "+Hostname+" created from template "+Template;
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

    RED.nodes.registerType("init-container",InitContainerNode);
}

