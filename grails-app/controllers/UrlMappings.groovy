import grails.util.GrailsUtil

class UrlMappings {

    static mappings = {
       if(GrailsUtil.getEnvironment() == "development") {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

          "/oai"(controller:"oai", action: {params.verb}) {
            constraints {
              action (matches: /\d+/)
            }
          }

        // "/"(view:"/index")
        //"500"(view:'/error')
        //"404"(view:'/notFound')
      }
      else { //if(GrailsUtil.getEnvironment() == "production") {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

          "/"(controller:"oai", action: {params.verb}) {
            constraints {
              action (matches: /\d+/)
            }
          }
      }
    }
}
