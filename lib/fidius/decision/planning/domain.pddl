; Security Domain for attackers 
;
; DANGER: Sensing Actions !!
;    Usage with contingent Planners only
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
  (:predicates
   ; Host predicates

   ; is a webserver running
   (webserver_running ?host)
   
   ; Current host = ?host
   (on_host ?host)                 
   ; ?service running on ?host
   (service_running ?host  ?service ) 
   ; admin password weak ?
   (password_crackable ?host )
   (shadow_reachable ?host )
   (shadow_decryptable ?host )
   
   ; user creatable host ?
   (user_creatable ?host)
   ; Is an anti virus software installed on host ? 
   (virus_scanner ?host )           
   ; is the host a domain controller ?
   (dc ?host )

   
   ; Network predicates

   ; Is host ?target visible from ?host ?
   (host_visible ?host  ?target )  
   ; In which ?subnet is ?host located ?
   (host_subnet ?host  ?subnet )      
   ; Current subnet = ?subnet ?
   (in_subnet ?subnet )          
   ; Is an IDS installed in subnet ? 
   (nids ?subnet )          
   
   ; Hacking status predicates
   ; is admin on host
   (admin ?host )
   ; server owned in net ?
   (server_owned ?net )
   ; is a host exploited ?
   (exploited ?host )
   ; is a trap like an iFrame injected in a subnet
   (trap_in_subnet ?subnet )
   ; is an iFrame injected on a host
   (iframe_injected ?host)
   ; is one host plumed in subnet ?
   (plumbed ?host)                  
   (plumb_in ?subnet)               
   ; is a domain controller under our controll ?
   (pwned_dc ?subnet)

   ; Reconaissance
   ; is host a server
   (is_server ?host)
  )

  ; --------------------- ;
  ;      TRAPPING         ;
  ; ----------------------;

  ; inject an iFrame in a host
  (:action inject_iframe
   :parameters(?host ?subnet )
   :precondition(and(on_host ?host)                            ; acting on host
                    (and(webserver_running ?host)              ; is a web server running
		         (in_subnet ?subnet)))                 ; action in subnet
   :effect(and(iframe_injected ?host)(trap_in_subnet ?subnet)) ; iframe injected on host, trap in subnet
   )

  ; is a webserver running ? 
  (:action check_httpd
   :parameters(?host)
   :precondition(on_host ?host)      ; acting on host
   :observe(webserver_running ?host) ; sensing action webserver
   )

  ; --------------------- ;
  ;      PLUMBING         ;
  ; ----------------------;
  
  ; get root access
  (:action become_admin
   :parameters(?host  ?subnet )	   
   :precondition(and (and (on_host ?host)                     ; acting on host
			      (host_subnet ?host ?subnet))    ; init subnet
			 (or (password_crackable ?host)       ; password weak or user creatable
			     (user_creatable ?host)))
   
   :effect(and (plumb_in ?subnet) (admin ?host))              ; host plumbed and mark the subnet as plumbed
   )

  ; install bridge head on host
   (:action install_bridge_head              
   :parameters(?host  ?subnet )
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
   :parameters(?host  ?target  ?targetnet  ?subnet )
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
   :parameters(?host  ?target  ?targetnet  ?subnet )
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
   :parameters(?host )
   :precondition(and (on_host ?host)                   ; action on host
		     (and (shadow_reachable ?host)     ; etc/shadow is accessible with current user rights
		          (shadow_decryptable ?host))) ; the shadow file is decryptable
   :effect(password_crackable ?host)                   ; then we can crack the password
   )
  
  ; pwn domain controller
  (:action pwn_dc
   :parameters(?host  ?subnet )	    
   :precondition(and (dc ?host)                               ; is the host a domain controller ? 
		     (and (password_crackable ?host)          ; password weak 
			  (and (on_host ?host)                ; acting on host  
			       (host_subnet ?host ?subnet)))) ; init subnet
  
   :effect(pwned_dc ?subnet)     
   )
  
  ; Perform exploit
  (:action exploit
   :parameters(?host  ?service  ?target   ?targetnet )
   :precondition(and (and (host_subnet ?target ?targetnet)    ; just initialize targetnet
			  (and (host_visible ?host ?target)   ; target reachable from host
			       (on_host ?host)))              ; currently acting on host 
			  (service_running ?target ?service)) ; the service is running

   :effect(exploited ?target)                                 ; mark the target as exploited
   )
  
  ; scan a host for services nmap
  (:action scan
   :parameters(?host  ?target  ?service ?targetnet )
   :precondition(and (and (on_host ?host)                    ; currently acting on host
			  (host_subnet ?target ?targetnet))  ; initialize target subnet		     
		     (and (host_visible ?host ?target)       ; target reachable from host
			  (not (nids ?targetnet))))          ; is a nids running
   :observe(service_running ?target ?service)
   )
  
  ; report server hacked in subnet
  (:action report_server
   :parameters(?host ?subnet )  
   :precondition(and (on_host ?host)              ; action on host of type server
	             (host_subnet ?host ?subnet)) ; action in subnet
   :effect(server_owned ?subnet)                  ; we hacked a server
  )
)