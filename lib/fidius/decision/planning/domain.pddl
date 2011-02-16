; Security Domain for attackers for contingent Planners
;
; cff: http://www.loria.fr/~hoffmanj/cff.html
;
; Daniel Kohlsdorf
; dkohl@tzi.de
;
; Project: FIDIUS
;
; University Bremen
(define (domain fidius)
  (:requirements :typing)
  (:types computer service net
	  server - computer
	  client - computer)  ; Client not used yet
  (:predicates
   ; Host predicates

   ; Current host = ?host
   (on_host ?host - computer)                 
   ; ?service running on ?host
   (service_running ?host - computer ?service - service) 
   ; admin password weak ?
   (password_crackable ?host - computer)
   (shadow_reachable ?host - computer)
   (shadow_decryptable ?host - computer)
   
   ; user creatable host ?
   (user_creatable ?host - computer)
   ; Is an anti virus software installed on host ? 
   (virus_scanner ?host - computer)           
   ; is the host a domain controller ?
   (dc ?host - computer)

   
   ; Network predicates
   
   ; Is host ?target visible from ?host ?
   (host_visible ?host - computer ?target - computer)  
   ; In which ?subnet is ?host located ?
   (host_subnet ?host - computer ?subnet - net)      
   ; Current subnet = ?subnet ?
   (in_subnet ?subnet - net)          
   ; Is an IDS installed in subnet ? 
   (nids ?subnet - net)          
   
   ; Hacking status predicates
   ; is admin on host
   (admin ?host - computer)
   ; server owned in net ?
   (server_owned ?net - net)
   ; is a host exploited ?
   (exploited ?host - computer)
   
   ; is one host plumed in subnet ?
   (plumbed ?host - computer)                  
   (plumb_in ?subnet - net)               
   ; is a domain controller under our controll ?
   (pwned_dc ?subnet - net)

   ; Reconaissance
   ; is host a server
   (is_server ?host)
  )

  ; --------------------- ;
  ;      PLUMBING         ;
  ; ----------------------;
  
  ; get root access
  (:action become_admin
   :parameters(?host - computer ?subnet - net)	   
   :precondition(and (and (on_host ?host)                 ; acting on host
			      (host_subnet ?host ?subnet))     ; init subnet
			 (or (password_crackable ?host)       ; password weak or user creatable
			     (user_creatable ?host)))
   
   :effect(and (plumb_in ?subnet) (admin ?host))              ; host plumbed and mark the subnet as plumbed
   )

  ; install bridge head on host
   (:action install_bridge_head              
   :parameters(?host - computer ?subnet - net)
   :precondition(and (and (on_host ?host)
			  (host_subnet ?host ?subnet))        ; acting on host
		     (not(virus_scanner ?host)))              ; no virus scanner
   
   :effect(plumb_in ?subnet)                                  ; host plumbed and mark the subnet as plumbed
   )

 

  ; --------------------- ;
  ;      MOVING           ;
  ; ----------------------;
  
  ; move from a ?host to exploited ?target
  (:action move_exploit
   :parameters(?host - computer ?target - computer ?targetnet - net ?subnet - net)
   :precondition(and (and (host_visible ?host ?target)           ; target reachable from host
			  (on_host ?host))                       ; currently acting on host 
		     (and (host_subnet ?target ?targetnet)       ; just initialize targetnet
			  (and  (or (exploited ?target)          ; target already exploited
				    (plumbed ?host))             ; from previous attacks
			        (host_subnet ?host ?subnet))))   ; access to the target

   :effect(and (and (in_subnet ?targetnet)                       ; move from host subnet to target targetnet
   	 	    (on_host ?target))
	       (not (on_host ?host)))
  )	 

  ; move from a ?host to ?target with granted access from domain controller
  (:action move_right
   :parameters(?host - computer ?target - computer ?targetnet - net ?subnet - net)
   :precondition(and (and (host_visible ?host ?target)           ; target reachable from host
			  (on_host ?host))                       ; currently acting on host 
		     (and (host_subnet ?target ?targetnet)       ; just initialize targetnet
			  (and  (pwned_dc ?targetnet)            ; access granted by domain controller
			        (host_subnet ?host ?subnet))))   ; access to the target

   :effect(and (and (in_subnet ?targetnet)                       ; move from host subnet to target targetnet
   	 	    (on_host ?target))
	       (not (on_host ?host)))
  )


  
  ; --------------------- ;
  ;      HACKING          ;
  ; ----------------------;

  ; crack a password
  (:action crack
   :parameters(?host - computer)
   :precondition(and (on_host ?host)
		     (and (shadow_reachable ?host)
		          (shadow_decryptable ?host)))
   :effect(password_crackable ?host)
   )
  
  ; pwn domain controller
  (:action pwn_dc
   :parameters(?host - computer ?subnet - net)	    
   :precondition(and (dc ?host)                               ; is the host a domain controller ? 
		     (and (password_crackable ?host)          ; password weak 
			  (and (on_host ?host)                ; acting on host  
			       (host_subnet ?host ?subnet)))) ; init subnet
  
   :effect(pwned_dc ?subnet)     
   )
  
  ; Perform exploit
  (:action exploit
   :parameters(?host - computer ?service - service ?target  - computer ?targetnet - net)
   :precondition(and (and (host_subnet ?target ?targetnet)    ; just initialize targetnet
			  (and (host_visible ?host ?target)   ; target reachable from host
			       (on_host ?host)))              ; currently acting on host 
			  (service_running ?target ?service)) ; the service is running

   :effect(exploited ?target) ; mark the target as exploited
   )
  
  ; scan a host for services nmap
  (:action scan
   :parameters(?host - computer ?target - computer ?service - service ?targetnet - net)
   :precondition(and (and (on_host ?host)                    ; currently acting on host
			  (host_subnet ?target ?targetnet))  ; initialize target subnet		     
		     (and (host_visible ?host ?target)       ; target reachable from host
			  (not (nids ?targetnet))))          ; is a nids running
   :observe(service_running ?target ?service)
   )

  ; report server hacked in subnet
  (:action report_server
   :parameters(?host - server ?subnet - net)
   :precondition(and (on_host ?host)
	             (host_subnet ?host ?subnet))
   :effect(server_owned ?subnet)
  )
)