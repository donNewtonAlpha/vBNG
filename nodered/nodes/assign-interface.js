var net=require("net");
var exec=require("child_process").exec;
var TemplateFile = "/home/foundry/vbng/sriov-tmpl.conf";
var ScriptPath = "/home/foundry/vbng/";
var RpsMask = 55;

module.exports = function(RED) {
  
    function AssignInterfaceNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);

        var node = this;
        node.Hostname=config.Hostname;
        node.SrIovInterface=config.SrIovInterface;

        this.on('input', function(msg) {
	    var SrIovInterface; 
            var Hostname;

	    if(msg.payload.Hostname==null){
	       Hostname=node.Hostname;
	    }else{
	       Hostname=msg.payload.Hostname;
	    }

	    if(msg.payload.SrIovInterface==null){
	       SrIovInterface=node.SrIovInterface;
	    }else{
	       SrIovInterface=msg.payload.SrIovInterface;
	    }

            if (msg.payload.Status==null){
               msg.payload.Status = "";
            }

            console.log("Hostname:"+Hostname);
            console.log("SrIovInterface:"+SrIovInterface);
            console.log("TemplateFile:"+TemplateFile);
            console.log("RpsMask:"+RpsMask);

            var command=ScriptPath+"/vbng-assign-interface.sh "+TemplateFile+" "+Hostname+" "+SrIovInterface+" "+RpsMask;
            console.log(command);

            var logprefix = "Container "+Hostname+" assigned interface "+SrIovInterface+" using template "+TemplateFile;
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

    RED.nodes.registerType("assign-interface",AssignInterfaceNode);
}

