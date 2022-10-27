({
    getRecord : function(component) {
	var fields = "Description,CallObject,CallDisposition";
	var recordId = component.get("v.recordId");
	var action = component.get("c.getRecords");
	var fieldList = fields.split(',');
	var fieldMap = new Object();
	console.log(fieldList);
	component.set("v.fieldList",fieldList);
	action.setParams({ recordId:recordId,fieldsToShow:fields });
  
	action.setCallback(this,function(a){
	    console.log(a.getReturnValue());
	    var sobjectrecord = a.getReturnValue();
	    for (var idx in fieldList) {
		console.log(fieldList[idx]);
		console.log(sobjectrecord[fieldList[idx]]);
		component.set("v.CallObject",sobjectrecord["CallObject"]);
		component.set("v.Disposition",sobjectrecord["CallDisposition"]);
		component.set("v.Description",sobjectrecord["Description"]);
		$A.createComponent(
			"ui:inputText",{
			    "label": fieldList[idx],
			    "value": sobjectrecord[fieldList[idx]],
			    "class": "outputCls",
			    "disabled":true
			},
			function(newCmp){
			    //Add the field list to the body array
			    if (component.isValid()){
				var body = component.get("v.body");
				body.push(newCmp);
				component.set("v.body", body);
			    }
			});
    
	    }
	    component.set("v.detailRecord",a.getReturnValue());
	});
	$A.enqueueAction(action);
	},
     publishMCS: function(cmp, msg) {
    	
        var message = {
            message1: msg,
            source: "Lightning"
        };
        cmp.find("ctiAuraMessageChannel").publish(message);
    }
})