({
    doInit : function(component, event, helper) {
        
        var det = component.get("c.getRecommendedPkg");
        det.setParams({
            "recID":   component.get("v.recordId") 
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                var temp=[];
                var recommended='<tr><th></th>';
                var tableheader='<tr><td style="border-left:1px solid lightgrey;border-bottom:1px solid lightgrey;font-weight: inherit;font-size: 2em;border-top:1px solid lightgrey;border-right:1px solid lightgrey;"><b>Essentials</b>	</td>';
                var Ad_Credits='<tr><td style="border-left:1px solid lightgrey;">Ad Credits</td>';
                var Agent_Profile='<tr><td style="border-left:1px solid lightgrey;border-bottom:1px solid lightgrey;">Agent Profile</td>';
                var Commercial_Listing='<tr><td style="border-left:1px solid lightgrey;">Commercial Listing</td>';
                var Concurrent_Listings='<tr><td style="border-left:1px solid lightgrey;">Concurrent Listings</td>';
                var Floor_Plans='<tr><td style="border-left:1px solid lightgrey;">Floor Plans / mnth</td>';
                for ( var key in response.getReturnValue().essentialList ) {
                    
                    if(response.getReturnValue().essentialList[key].isRecommended){
                        recommended+='<th style="background: #42ba84;">Recommended';
                    }else
                        recommended+='<th>'
                        recommended+='</th>'
                        tableheader += '<td style="border-top:1px solid lightgrey;border-bottom:1px solid lightgrey;"><div><b style="font-size: large">'+response.getReturnValue().essentialList[key].Name+'</b></div><div>'+response.getReturnValue().essentialList[key].price+' / '+response.getReturnValue().essentialList[key].validity+'</div><div>'+response.getReturnValue().essentialList[key].perDay+' / Day </div></td>';
                    Ad_Credits +='<td>'+response.getReturnValue().essentialList[key].essentials['Ad Credits']+'</td>';
                    Agent_Profile+='<td style="border-bottom:1px solid lightgrey;">';
                    if(response.getReturnValue().essentialList[key].essentials['Agent Profile'] == true){
                        // Agent_Profile +='<lightning:icon iconName="action:approval" title="Approved"  size="small" />';
                        // Agent_Profile   +='&#10003;'   ;
                        Agent_Profile+='<i class="fa fa-check-circle" style="font-size:48px;color:#0e9e59"></i>';
                    }
                    Agent_Profile+='</td>';
                    // Agent_Profile +='<td>'+response.getReturnValue().essentialList[key].essentials['Agent Profile']+'</td>';
                    
                    //Commercial_Listing +='<td>'+response.getReturnValue().essentialList[key].essentials['Commercial Listing']+'</td>';
                    Commercial_Listing+='<td>';
                    if(response.getReturnValue().essentialList[key].essentials['Commercial Listing'] == true){
                        
                        Commercial_Listing+='<i class="fa fa-check-circle" style="font-size:48px;color:#0e9e59"></i>';
                    }
                    Commercial_Listing+='</td>';
                    Concurrent_Listings +='<td>'+response.getReturnValue().essentialList[key].essentials['Concurrent Listings']+'</td>';
                    Floor_Plans +='<td>'+response.getReturnValue().essentialList[key].essentials['Concurrent Listings']+'</td>';
                    
                    /* temp.push({
                        Ad_Credits:response.getReturnValue().essentialList[key].essentials['Ad Credits'],
                        Name:response.getReturnValue().essentialList[key].Name,
                        Agent_Profile:response.getReturnValue().essentialList[key].essentials['Agent Profile'],
                        Commercial_Listing:response.getReturnValue().essentialList[key].essentials['Commercial Listing'],
                        Concurrent_Listings:response.getReturnValue().essentialList[key].essentials['Concurrent Listings'],
                        Floor_Plans:response.getReturnValue().essentialList[key].essentials['Floor Plans/mnth'],
                        isRecommended:response.getReturnValue().essentialList[key].isRecommended,
                        perDay:response.getReturnValue().essentialList[key].perDay,
                        price:response.getReturnValue().essentialList[key].price,
                        validity:response.getReturnValue().essentialList[key].validity
                    });*/
                    
                    //console.log(response.getReturnValue()[key].essentialList.essentials);
                    
                }
                recommended+='</tr>';
                tableheader += '</tr>';
                Ad_Credits +='</tr>';
                Agent_Profile += '</tr>';
                Commercial_Listing += '</tr>';
                Concurrent_Listings += '</tr>';
                Floor_Plans += '</tr>';
                /* <td>Essentials</td>
                <td>Concurrent Listings</td>
                <td>Ad Credits</td>
                <td>Floor Plans/mnth</td>
                <td>Commercial Listing</td>
                <td>Agent Profile</td>*/
                var finalTable='<table>'+recommended+tableheader+Concurrent_Listings+Ad_Credits+Floor_Plans+Commercial_Listing+Agent_Profile+'</table>';	
                console.log(temp);
                
                component.set("v.tableData",finalTable);
                component.set("v.data",temp);
                component.set("v.isSuccess",true);
                
                console.log(response);
                //                component.set("v.message",'Event published successfully')
                // helper.showToast(component, event, helper,'Success','SMS send successfully','success');       
            }
            else{
                component.set("v.message",response.getError()[0].message);
                component.set("v.isSuccess",false);
                // helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
                
            }
        });
        $A.enqueueAction(det);
        
        
    },
})