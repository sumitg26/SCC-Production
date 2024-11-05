trigger parentAccountEmailActivity on Task (before insert) {
    Set<Id> accIds= new Set<Id>();
    for(Task t : trigger.new){
        if(t.WhatId!=null){
            String wId = t.WhatId; 
            if(wId.startsWith('001') && !accIds.contains(t.WhatId)){
                accIds.add(t.WhatId); 
            }
        }
    }
    Map<ID,Account> parentAccMap = new Map<ID,Account>([Select Id,ParentId, Name FROM Account WHERE ID IN :accIds AND ParentID!=null]);
    for(Task t : trigger.new){
    String taskSubject = t.subject;
        if(t.WhatId!=null && t.subject.contains('Email:') && parentAccMap!=null && parentAccMap.size()>0 && parentAccMap.containsKey(t.WhatId)){
            t.WhatId = parentAccMap.get(t.WhatId).ParentId;
        }
    }
}