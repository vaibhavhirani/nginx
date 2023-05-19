A nginx web server to host any application.

* setTfEnv.sh
    - Creates service principal user in your default azure subcription.
    - Sets the ARM environment variable for terraform to plan and apply changes using sp.

* nginxHost.tf
    - Terraform script to provision ubuntu vm on azure.