package Cx

import data.generic.ansible as ansLib
import data.generic.common as common_lib

modules := {"community.aws.elb_network_lb", "elb_network_lb", "community.aws.elb_application_lb", "elb_application_lb"}

CxPolicy[result] {
	task := ansLib.tasks[id][t]
	elb := task[modules[m]]
	ansLib.checkState(elb)

	not common_lib.valid_key(elb, "listeners")

	result := {
		"documentId": id,
		"resourceType": modules[m],
		"resourceName": task.name,
		"searchKey": sprintf("name={{%s}}.{{%s}}", [task.name, modules[m]]),
		"issueType": "MissingAttribute",
		"keyExpectedValue": sprintf("%s.listeners is defined", [modules[m]]),
		"keyActualValue": sprintf("%&s.listeners is undefined", [modules[m]]),
	}
}

CxPolicy[result] {
	task := ansLib.tasks[id][t]
	elb := task[modules[m]]
	ansLib.checkState(elb)

	listener := elb.listeners[j]
	not common_lib.valid_key(listener, "SslPolicy")

	result := {
		"documentId": id,
		"resourceType": modules[m],
		"resourceName": task.name,
		"searchKey": sprintf("name={{%s}}.{{%s}}.listeners.%s", [task.name, modules[m], j]),
		"issueType": "MissingAttribute",
		"keyExpectedValue": sprintf("%s.listeners.SslPolicy is defined", [modules[m]]),
		"keyActualValue": sprintf("%s.listeners.SslPolicy is undefined", [modules[m]]),
	}
}

CxPolicy[result] {
	task := ansLib.tasks[id][t]
	elb := task[modules[m]]
	ansLib.checkState(elb)

	common_lib.weakCipher(elb.listeners[j].SslPolicy)

	result := {
		"documentId": id,
		"resourceType": modules[m],
		"resourceName": task.name,
		"searchKey": sprintf("name={{%s}}.{{%s}}.listeners.%s", [task.name, modules[m], j]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("%s.listeners.SslPolicy should not be a weak cipher", [modules[m]]),
		"keyActualValue": sprintf("%s.listeners.SslPolicy is a weak cipher", [modules[m]]),
	}
}
