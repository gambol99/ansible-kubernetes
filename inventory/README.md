## **Anisible Inventory**

At present and not to suggest this is the best way of doing it, just the way I choose, dynamic inventory is provided for AWS, VMware Directory and Vagrant, all the provider are run through the groups.yml using regexes to defined the hostgroups the boxes should be in. Technically, we could also you tags and metadata, though the only advantage this would give would be to apply a deviation to the normal, i.e. a box X which has X,Y,X, but for some reason you want A and B roles to run on it. It's a possibility, so I've leaving the decision up to grabs.


### **Crendentials**

A .credentials file must be created in the inventory; essentially an array of stacks (locations) with the associated usernames, passwords, endpoints etc. The formated being

    [NAME|LOCATION]
      OPTIONS

    e.g.

    eu1:
      aws-key: KEYKEY
      aws-secret: BLAHBLAH

   