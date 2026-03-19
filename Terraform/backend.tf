terraform { 
  cloud { 
    
    organization = "Zboromir-org" 

    workspaces { 
      name = "chaos-k3s" 
    } 
  } 
}
