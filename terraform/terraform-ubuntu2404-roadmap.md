# Terraform AWS Roadmap – Ubuntu 24.04

Το παρόν έγγραφο λειτουργεί ως **πλήρης οδηγός εκτέλεσης (user guide / roadmap)** για
την ανάπτυξη και διαχείριση υποδομής νέφους με χρήση **Terraform** σε περιβάλλον
**Ubuntu 24.04**, αξιοποιώντας την πλατφόρμα **AWS**.

Ο οδηγός περιγράφει αναλυτικά:

- όλα τα βήματα που απαιτούνται από ένα «καθαρό» σύστημα,
- τη διάκριση των φάσεων **prepare / deploy / destroy**,
- τις μεταβλητές που χρησιμοποιούνται,
- καθώς και τον σωστό τρόπο ολοκλήρωσης και καθαρισμού της υποδομής.

## Αρχιτεκτονικό Πεδίο και Ρητός Περιορισμός

Ο οδηγός αφορά **αποκλειστικά** τη διαχείριση του κύκλου ζωής της υποδομής IaaS
(prepare → deploy → destroy) με Terraform σε AWS. Η **εγκατάσταση/εκτέλεση της
επιχειρησιακής λογικής** της εφαρμογής (citizen-service JAR, systemd service,
runtime pipeline) **δεν απαιτείται από την εκφώνηση** και δεν αποτελεί μέρος του
παρόντος οδικού χάρτη. Η AMI της φάσης prepare περιλαμβάνει μόνο το runtime
περιβάλλον, ώστε να αναδεικνύεται η εστίαση στην υποδομή.

## Προαπαιτούμενα Συστήματος

- Λειτουργικό σύστημα: **Ubuntu 24.04 LTS**
- Πρόσβαση σε λογαριασμό **AWS**
- IAM user με δικαιώματα:
  - AmazonEC2FullAccess
  - ElasticLoadBalancingFullAccess
- Σύνδεση στο διαδίκτυο

## Βήμα 1 – Εγκατάσταση Εργαλείων στο Ubuntu 24.04

### Ενημέρωση Συστήματος

```bash
sudo apt update
sudo apt upgrade -y
```

### Εγκατάσταση AWS CLI v2

```bash
sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Έλεγχος:

```bash
aws --version
```

### Εγκατάσταση Terraform (επίσημο HashiCorp repository)

```bash
sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y
```

Έλεγχος:

```bash
terraform --version
```

## Βήμα 2 – Ρύθμιση AWS CLI

```bash
aws configure
```

Παράμετροι:

- AWS Access Key ID
- AWS Secret Access Key
- Region: `<AWS_REGION>`
- Output format: `json`

Έλεγχος:

```bash
aws sts get-caller-identity
```

## Βήμα 3 – Δημιουργία EC2 Key Pair

Το EC2 Key Pair χρησιμοποιείται αποκλειστικά για SSH πρόσβαση στα instances.

```bash
aws ec2 create-key-pair \
  --key-name <EC2_KEY_PAIR_NAME> \
  --query 'KeyMaterial' \
  --output text > <EC2_KEY_PAIR_NAME>.pem

chmod 400 <EC2_KEY_PAIR_NAME>.pem
```

Σημείωση:

- Το όνομα `<EC2_KEY_PAIR_NAME>` αποθηκεύεται στο AWS.
- Το αρχείο `.pem` παραμένει τοπικά και δεν χρησιμοποιείται από το Terraform.

## Δομή Terraform Έργου

```text
terraform/
├── prepare/
├── deploy/
└── destroy/
```

Κάθε φάση αποτελεί αυτόνομο στάδιο του κύκλου ζωής.

## Φάση 1 – Prepare (Δημιουργία Εικόνας)

### Σκοπός

Δημιουργία AMI που περιλαμβάνει το περιβάλλον εκτέλεσης της RESTful υπηρεσίας.

### Μεταβλητές (prepare)

Δηλώνονται στο:

```text
terraform/prepare/variables.tf
```

| Μεταβλητή | Ρόλος              |
| ------------------ | ----------------------- |
| aws_region         | Περιοχή AWS      |
| base_ami           | Ubuntu AMI βάσης   |
| key_name           | Όνομα EC2 Key Pair |

### Αποθήκευση τιμών

```text
terraform/prepare/terraform.tfvars
```

Παράδειγμα:

```hcl
base_ami = "<UBUNTU_BASE_AMI_ID>"
key_name = "<EC2_KEY_PAIR_NAME>"
```

Οι τιμές στο παράδειγμα είναι placeholders και αντικαθίστανται από πραγματικές τιμές πριν την εκτέλεση.

### Εκτέλεση

```bash
cd terraform/prepare
terraform init
terraform apply
```

### Παραγόμενο artefact

- `rest_ami_id` (AMI της REST υπηρεσίας)

Αυτό το AMI χρησιμοποιείται υποχρεωτικά στη φάση deploy.

## Φάση 2 – Deploy (Διάταξη Υποδομής)

### Σκοπός

Δημιουργία πλήρους υποδομής:

- 3 REST EC2 instances
- 1 DB EC2 instance
- Application Load Balancer (ALB)
- VPC, subnets, security groups

### Μεταβλητές (deploy)

Δηλώνονται στο:

```text
terraform/deploy/variables.tf
```

| Μεταβλητή | Ρόλος           |
| ------------------ | -------------------- |
| aws_region         | Περιοχή AWS   |
| rest_ami           | AMI από prepare   |
| db_ami             | Ubuntu AMI για DB |
| key_name           | EC2 Key Pair         |
| db_port            | Θύρα DB (3306)   |

### Αποθήκευση τιμών

```text
terraform/deploy/terraform.tfvars
```

Παράδειγμα:

```hcl
rest_ami = "<REST_SERVICE_AMI_ID>"
db_ami   = "<DB_AMI_ID>"
key_name = "<EC2_KEY_PAIR_NAME>"
```

Οι τιμές στο παράδειγμα είναι placeholders και αντικαθίστανται από πραγματικές τιμές πριν την εκτέλεση.

### Εκτέλεση

```bash
cd terraform/deploy
terraform init
terraform apply
```

### Αποτελέσματα

- Δημιουργία εξισορροπητή φορτίου (Load Balancer, multi-AZ)
- Private REST & DB instances

Outputs:

- `load_balancer_dns`
- `rest_private_ips`
- `db_private_ip`

## Φάση 3 – Destroy (Καθαρισμός Υποδομής)

### Σκοπός

Πλήρης αποδέσμευση όλων των πόρων νέφους.

### Εκτέλεση

```bash
cd terraform/deploy
terraform destroy
```

Επιβεβαίωση:

```text
yes
```

Προαιρετικά:

```bash
cd terraform/prepare
terraform destroy
```

## Παρατηρήσεις για τις Μεταβλητές

- Οι μεταβλητές **δεν** hardcoded μέσα στα `.tf` αρχεία.
- Οι τιμές αποθηκεύονται σε `terraform.tfvars` (ξεχωριστό αρχείο ανά φάση).
- Το artefact της prepare (`rest_ami_id`) μεταφέρεται χειροκίνητα στο deploy.
