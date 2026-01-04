@Suntorio MY PROJECT TO DEPLOY ANOTHER GAME (SPACE-INV):
1. VALUE name&namepsace "pacman" WILL BE CHANGED TO "spaceinv"
2. Service "pac-man" WILL BE CHANGED TO "space-inv"



1. Do this step just once!!! run command “sudo visudo” on Jenkins server and add string(running pipeline without passw request):
   jenkins ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/curl, /usr/bin/tee, /usr/bin/apt-key, /usr/bin/sh
2. Add AWS instance access key to the Jenkins credentials for the ancible playbook running (kind: SSH Username with private key) Do it once!!!
3. Find at the Jenkins logs certificate-authority-data JSON and convert it into YAML(https://onlineyamltools.com/convert-json-to-yaml)
4. On local PC or any instance with kubectl “cd ~/.kube” and run “sudo nano config”. Insert YAML config into config, and insert  MASTER-NODE IP and save it(IPMASTER:6443)
6. kubectx (check namespace) We need default namespace(#kubectx namespace# use it, if you need to change namespace)
5. Check connection “kubectl get nodes” (If you can see pods, it means we are connected to our cluster. We can see information for each pod like name, status, roles, age, and version)
6. (open second terminal window for convenience) After we connected to the cluster, we need to go to my(your) repository locally: Lessons NEXT k3s_cluster_aws_jenkins_nginx NEXT cluster_init  NEXT  aws_ingress_setup and run there two commands:
   kubectl apply -f 1.metallb.yaml (run LoadBalancer)
   kubectl apply -f 2.nginx-ingress.yaml (nginx ingress controller)
After you ran two commands in the terminal, you can go and open your OpenLens and you can see there is everything were applied correctly and running. Go to DE(default), network(services). If we see IP-address, it means everything is working.
8. Deploying PACMAN. Go to my repository locally: Lessons - k3s_cluster_aws_jenkins_nginx NEXT cluster_entities/pacman
     kubectl apply -f mongo-deployment.yaml (running DB first of all)
     kubectl apply -f packman-deployment.yaml
     kubens (run it to see namespaces)
     kubens pacman (choose namespace pacman)
     kubectl get pods (run to see what pods you have)
     # kubectl get pods -A (OPTIONAL, to check how many pods total do we have)
     Go to the OpenLens, network-service(you can see that we got one more servece, pacman. Type of service is LB, because it’s
     serviced by metallb)
#  8.  Create Route 53 in AWS(only if you have your own IP)
#  Copy master node IP NEXT go to serch area and type Route 53 NEXT click on HoustedZone #  NEXT click on Craete Record NEXT insert master IP into value section.
9. run command: curl insert(public IPv4 DNS). If you see some information like “head”, means it is working.
10. If you do not have Route 53 do next: in pacman-deployment.yaml in line 22 put Master node public IPv4 DNS (example how it’s looks like:ec2-54-146-202-253.compute-1.amazonaws.com). Next, you need to apply this, so run this command at pacman namespace in the terminal: kubectl apply -f packman-deployment.yaml
11. run command: curl insert(public IPv4 DNS). If you see some information like “head”, means it is working.


# Add 2nd game to the cluster:
Oleksii Pasichnyk
:smiling_imp:  10 minutes ago
хм, если тестировать локально то да, если в кластер в авс выгружаешь то нет.
у aws нет доступа к локальному имейджу, надо имейдж залить в докерхаб.
чтобы залить в докерхаб надо
создать аккаунт
создать там репозиторий
если репозиторий паблик, а тебе лучше его делать паблик тогда пароли  для скачивания не нужны, если прайват тогда надо будет еще логин и пароль сетапить, прайват бесплатный только один

Oleksii Pasichnyk
:smiling_imp:  9 minutes ago
есть и другие варианты но это то с чем я промаялся 2 месяца - где хранить имейджы и как сделать локальное хранилище для кластера, в результате докер хаб самое эффективное решение и простое

п.с. правильно путь прописать надо еще будет, дойдешь до этого этапа пиши