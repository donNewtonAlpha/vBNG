var net=require("net");
var exec=require("child_process").exec;

module.exports = function(RED) {
  
    function HostNode(config) {
        RED.nodes.createNode(this,config);
        console.log(config);

        var node = this;
        node.Action=config.Action;

        this.on('input', function(msg) {
            var Action;

	    if(msg.payload.Action==null){
	       Action=node.Action;
	    }else{
	       Action=msg.payload.Action;
	    }

            if (msg.payload.Status==null){
               msg.payload.Status = "";
            }

            var command="";

            if (Action == "list-containers") {
              command = "lxc-ls -f -F NAME,STATE";
            } else {
              node.error("No action passed", msg);
              return;
            }

            console.log(command);

            var logprefix = "Host command "+Action;
            exec(command,(error,stdout,stderr)=>{
                 if(stderr!=""){
                    msg.payload.Status += "FAILED:"+logprefix+":"+stderr+".";
                    node.error(msg.payload.Status, msg);
                 }else{
                    listresp = [];
                    var lines = stdout.split('\n');
                    for(var i = 0;i < lines.length;i++){
                      var entry = {};
                      entry.Hostname = lines[i].split(/\s+/)[0];
                      entry.Status = lines[i].split(/\s+/)[1];

                      if (entry.Hostname == "" || entry.Hostname == "NAME") {
                         continue;
                      }

                      listresp.push(entry);
                    }

                    msg.payload = listresp;
                    console.log(msg.payload);
                    node.send(msg);
                 }
            });

        });
    }

    RED.nodes.registerType("host",HostNode);
}

