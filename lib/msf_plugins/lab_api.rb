##
## $Id$
##

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'lab'))

require 'yaml'
require 'vm_controller'

module Msf

  class Plugin::LabApi < Msf::Plugin
    attr_accessor :lab_api
    class LabApi
    
      def initialize
        @controller = ::Lab::Controllers::VmController.new
      end
      
      def lab_show
        tbl = []
        @controller.each do |vm| 
					tbl << [ vm.vmid, vm.location, vm.running?]
				end
				return tbl
      end
      
      def lab_show_running
        tbl = []
        @controller.each do |vm| 
					tbl << [ vm.vmid, vm.location, vm.running?]  if vm.running? 
				end
				return tbl
      end
      
      def lab_load yaml_file
        return -1 if yaml_file == nil || yaml_file.empty?
        @controller.from_file(yaml_file)
      end
      
			def lab_save file_path
			  return -1 if file_path == nil || file_path.empty?
			  @controller.to_file(file_path)  
			end
			
			def lab_load_running
			  
			end
			
			def lab_load_config
			  
			end
			
#			def lab_load_dir
#			 
#			end			
			
			def lab_clear
			  @controller.clear!
			end
			
			def lab_start var
			  return -1  if check_vm_param(var)
			  		
  			if var.class == String && var == "all"
				  @controller.each { |vm| 
				    #Logging	
					  vm.start  if !vm.running?
				  }
  			else 
  			  var = [var]  if var.class == String
  				var.each { |arg|
  					if @controller.includes_vmid? arg
  						vm = @controller.find_by_vmid(arg)	
  						vm.start  if !vm.running?
  					end	
  				}
  			end
			end
			
			def lab_reset var
			  return -1  if check_vm_param(var)
		
  			if var.class == String && var == "all"
  				#logging
  				@controller.each{ |vm| vm.reset }
  			else
  			  var = [var]  if var.class == String
  				var.each { |arg|
  					if @controller.includes_vmid? arg
  						#logging
  						@controller.find_by_vmid(arg).reset	
  					end	
  				}
  			end
			end
			
			def lab_suspend var
			  return -1  if check_vm_param(var)
					
  			if var.class == String && var == "all"
  				@controller.each{ |vm| vm.suspend}
  			else
  			  var = [var]  if var.class == String
  				var.each do |arg|
  					if @controller.includes_vmid? arg
  						#logging
  						@controller.find_by_vmid(arg).suspend	
  					end	
  				end
  			end
			end
			
			def lab_stop var
			  return -1  if check_vm_param(var)
			  		
  			if var.class == String && var == "all"
				  @controller.each { |vm| 
				    #Logging	
					  vm.stop  if vm.running?
				  }
  			else 
  			  var = [var]  if var.class == String
  				var.each { |arg|
  					if @controller.includes_vmid? arg
  						vm = @controller.find_by_vmid(arg)	
  						vm.stop  if vm.running?
  					end	
  				}
  			end			  
			end
			
			def lab_revert vmids, snapshot
			  return -1  if check_vm_param(vmids) || snapshot.empty?
			  snapshot = args[args.count-1] 		

  			if vmids.class == String && vmids == "all"
  				#Logging	
  				@controller.each{ |vm| vm.revert_snapshot(snapshot) }
  			else
  			  vmids = [vmids]  if vmids.class == String
  				vmids.each do |vmid_arg|
  					next unless @controller.includes_vmid? vmid_arg
  					#Logging	
  					@controller[vmid_arg].revert_snapshot(snapshot)	
  				end
  			end
			end
			
			def lab_snapshot vmids, snapshot
			  return -1  if check_vm_param(vmids) || snapshot.empty?
		
  			if vmids == "all"
  				#Logging	
  				@controller.each{ |vm| vm.create_snapshot(snapshot) }
  			else
  			  vmids = [vmids]  if vmids.class == String
  				vmids.each do |vmid_arg|
  					next unless @controller.includes_vmid? vmid_arg
  					#Logging	
  					@controller[vmid_arg].create_snapshot(snapshot)
  				end
  			end
			end  
			
			private
			
			def check_vm_param param
			  return (param == nil || (param.class == Array && param.empty?)) || (param.class == String && param.empty?)
			end   
      
    end
    module Lab::LabApi
      def lab_api
        plugins.each { |plugin|
          return plugin.lab_api if plugin.name == "lab_api"          
        }
        return nil
      end
    end
  	def initialize(framework, opts)
  		super
  		self.lab_api = LabApi.new
  		framework.extend(Lab::LabApi)
  	end

  	def cleanup
  	end

   	def name
  		"lab_api"
  	end

  	def desc
  		"Adds the lab api to the MSF-Framework"
  	end
  	
  end ## End Class
end ## End Module
