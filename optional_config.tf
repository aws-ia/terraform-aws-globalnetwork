
//#-----------------------------------------------------------------------------------------------------
//#  AWS Transit Gateway | ---> Enables the deployment of a transit gateway in the specified region
//#-----------------------------------------------------------------------------------------------------
//variable "transit_gateway_deployment" {
//  default = true
//  validation {
//    condition     = (var.transit_gateway_deployment == false || var.transit_gateway_deployment == true)
//    error_message = "Transit Gateway deployment must be either true or false."
//  }
//}
//


//variable "dns_support" {
//  default = "disable"
//}


//variable "auto_accept_shared_attachments" {
//  default = "enable"
//}

//variable "allow_external_principals" {
//  default = false
//  validation {
//    condition     = (var.allow_external_principals == false)
//    error_message = "External Principals should not be allowed unless in the case of a merger."
//  }
//}

