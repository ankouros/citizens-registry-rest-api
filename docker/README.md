## Δοχειοποίηση Εφαρμογών (Application Containerisation)

## 1. Εισαγωγή

Η εργασία υλοποιείται με τη χρήση του **Docker** και του **Docker Compose** και περιλαμβάνει:

* δοχειοποίηση της RESTful υπηρεσίας,
* χρήση δοχείου για το υποκείμενο Σύστημα Διαχείρισης Βάσεων Δεδομένων (ΣΔΒΔ),
* διαχείριση της διάταξης (deployment) μέσω scripts και docker-compose,
* εφαρμογή βασικών καλών πρακτικών ασφάλειας.

## 1.1 Αρχιτεκτονικό Πεδίο

Η παρούσα τεκμηρίωση αφορά **αποκλειστικά** τη δοχειοποίηση του backend
(`citizen-service`) και την ενσωμάτωση ενός ΣΔΒΔ μέσω Docker. Δεν καλύπτονται
ζητήματα CI/CD, ορχήστρωσης (π.χ. Kubernetes) ή πολιτικών παραγωγικής
διάθεσης, καθώς το αντικείμενο της ενότητας είναι η **αναπαραγώγιμη εκτέλεση**
σε περιβάλλον containers και όχι η αυτοματοποίηση παράδοσης λογισμικού.

## 2. Δομή του έργου

Το έργο είναι **multi-module Maven project** και αποτελείται από τα ακόλουθα βασικά modules:

* `citizen-domain`: κοινό domain model (POJOs)
* `citizen-service`: RESTful backend υπηρεσία (**δοχειοποιείται**)
* `citizen-client`: client εφαρμογή
* `citizen-it`: integration tests

Η δοχειοποίηση αφορά **αποκλειστικά το module `citizen-service`**, καθώς αυτό αποτελεί το backend της εφαρμογής.

Όλα τα αρχεία της παρούσας άσκησης βρίσκονται στον φάκελο:

```
docker/
```

## 3. Dockerfile – Δοχειοποίηση RESTful Υπηρεσίας

Για τη δοχειοποίηση της RESTful υπηρεσίας χρησιμοποιείται **multi-stage Dockerfile**.

### Βασικά χαρακτηριστικά:

* Χρήση **Maven image** για το build στάδιο.
* Υποστήριξη **multi-module Maven build** (συμπεριλαμβάνεται το `citizen-domain`).
* Χρήση **JRE image** στο runtime στάδιο.
* Εκτέλεση εφαρμογής με **μη ριζικό χρήστη**.
* Μικρότερο τελικό μέγεθος εικόνας και μειωμένη επιφάνεια επιθέσεων.

Το Dockerfile βρίσκεται στο:

```
docker/Dockerfile
```

### Διορθώσεις στο pom.xml

Κατά τη δοκιμή του Docker image εμφανίστηκε σφάλμα `no main manifest attribute`,
που υποδεικνύει ότι το JAR δεν έχει επανασυσκευαστεί ως Spring Boot executable.
Για τον λόγο αυτό προστέθηκε στο `citizen-service/pom.xml` ο στόχος `repackage`
του `spring-boot-maven-plugin`, ώστε το τελικό JAR να είναι εκτελέσιμο
και να εκκινεί σωστά μέσα στο container.

Επιπλέον, προστέθηκε **MySQL Connector/J** ως runtime dependency στο ίδιο pom.xml,
ώστε η εφαρμογή να μπορεί να συνδεθεί με MySQL όταν εκτελείται σε Docker
(σε συνδυασμό με τις αντίστοιχες ρυθμίσεις `SPRING_DATASOURCE_*`).

Στη συνέχεια, κατά το CI, διαπιστώθηκε ότι το repackaged JAR δεν είναι κατάλληλο
ως εξάρτηση για το module `citizen-it`, επειδή οι κλάσεις βρίσκονται στο
`BOOT-INF/classes`. Για να αποκατασταθεί αυτό, ορίστηκε **classifier** για το
εκτελέσιμο JAR (`exec`), ώστε να παράγεται **κανονικό** JAR για εξαρτήσεις και
το Docker να εκκινεί το `*exec.jar`.

## 4. Scripts Διαχείρισης Docker

### 4.1 build.sh

Το script:

* κατασκευάζει την εικόνα Docker της RESTful υπηρεσίας,
* δημιουργεί Docker volume για επίμονη αποθήκευση δεδομένων της βάσης.

### 4.2 startup.sh

Το script:

* δημιουργεί οριζόμενο Docker network,
* εκκινεί δοχείο MySQL από επίσημη εικόνα του Docker Hub,
* εκκινεί δοχείο της RESTful υπηρεσίας,
* επιτρέπει την επικοινωνία των δοχείων μέσω του Docker network,
* εκθέτει **μόνο** τη θύρα της RESTful υπηρεσίας στο τοπικό σύστημα.

Η επικοινωνία με τη βάση δεδομένων γίνεται μέσω του **ονόματος του δοχείου** (`mysql-db`) και όχι μέσω `localhost`.

Επιπλέον, για λειτουργία με MySQL προστέθηκε ο **MySQL Connector/J** στο
`citizen-service/pom.xml` και στο container περνιούνται οι μεταβλητές:
`SPRING_DATASOURCE_DRIVER_CLASS_NAME` και `SPRING_JPA_DATABASE_PLATFORM`,
ώστε ο driver και το Hibernate dialect να αντιστοιχούν στη MySQL.

### 4.3 shutdown.sh

Το script:

* σταματά και καταστρέφει τα δοχεία,
* αφαιρεί το Docker network,
* **δεν διαγράφει το volume**, ώστε τα δεδομένα της βάσης να παραμένουν διαθέσιμα.

## 5. Docker Compose – Μοντέλο Αρχιτεκτονικής Διάταξης

Η διάταξη της εφαρμογής περιγράφεται μέσω του αρχείου:

```
docker/docker-compose.yml
```

### Περιλαμβάνει:

* Υπηρεσία `citizen-service` (REST API)
* Υπηρεσία `db` (MySQL)
* Οριζόμενο Docker network
* Docker volume για επίμονη αποθήκευση δεδομένων

### Εφαρμοζόμενες καλές πρακτικές ασφάλειας:

* Η βάση δεδομένων **δεν εκθέτει θύρες** στο τοπικό σύστημα.
* Η RESTful υπηρεσία εκτελείται με **read-only filesystem**.
* Χρήση `no-new-privileges`.
* Χρήση επίσημης και αξιόπιστης εικόνας MySQL.

Η διάταξη εκτελείται με:

```bash
docker compose up -d
```

και τερματίζεται με:

```bash
docker compose down
```

## 6. Επίμονη Αποθήκευση Δεδομένων

Για το ΣΔΒΔ χρησιμοποιείται Docker volume:

```
citizen-db-data
```

Το volume αντιστοιχίζεται στον φάκελο:

```
/var/lib/mysql
```

Με αυτόν τον τρόπο:

* τα δεδομένα της βάσης διατηρούνται μετά από επανεκκίνηση δοχείων,
* είναι δυνατή η επαναχρησιμοποίηση της βάσης σε νέες εκτελέσεις.

## 7. Δοκιμές

### Οι δοκιμές επιβεβαιώνουν ότι η εφαρμογή παραμένει λειτουργική μετά από επανεκκίνηση των containers.

### 7.1 Δοκιμές με docker

Έλεγχος health:

```bash
curl -s -i http://localhost:8080/actuator/health
```

```
HTTP/1.1 200
Content-Type: application/vnd.spring-boot.actuator.v3+json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:41:43 GMT

{"status":"UP","components":{"db":{"status":"UP","details":{"database":"MySQL","validationQuery":"isValid()"}},"diskSpace":{"status":"UP","details":{"total":1967315451904,"free":1001979170816,"threshold":10485760,"path":"/app/.","exists":true}},"ping":{"status":"UP"}}}
```

Λίστα πολιτών:

```bash
curl -s -i http://localhost:8080/citizens
```

```
HTTP/1.1 200
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:41:48 GMT

[]
```

Δημιουργία πολίτη (POST):

```bash
curl -s -i -X POST http://localhost:8080/citizens \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Eleni","lastName":"Papadaki","afm":"111222333","amka":"04040412345","birthDate":"1993-04-04"}'
```

```
HTTP/1.1 201
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:41:53 GMT

{"id":1,"firstName":"Eleni","lastName":"Papadaki","afm":"111222333","amka":"04040412345","birthDate":"1993-04-04"}
```

Ανάκτηση πολίτη (GET /citizens/1):

```bash
curl -s -i http://localhost:8080/citizens/1
```

```
HTTP/1.1 200
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:41:56 GMT

{"id":1,"firstName":"Eleni","lastName":"Papadaki","afm":"111222333","amka":"04040412345","birthDate":"1993-04-04"}
```

Ενημέρωση πολίτη (PUT /citizens/1):

```bash
curl -s -i -X PUT http://localhost:8080/citizens/1 \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Eleni","lastName":"Papadaki-Updated","afm":"111222333","amka":"04040412345","birthDate":"1993-04-04"}'
```

```
HTTP/1.1 200
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:42:02 GMT

{"id":1,"firstName":"Eleni","lastName":"Papadaki-Updated","afm":"111222333","amka":"04040412345","birthDate":"1993-04-04"}
```

Διαγραφή πολίτη (DELETE /citizens/1):

```bash
curl -s -i -X DELETE http://localhost:8080/citizens/1
```

```
HTTP/1.1 204
Date: Fri, 23 Jan 2026 18:42:06 GMT
```

### 7.2 Δοκιμές με docker-compose

Έλεγχος health:

```bash
curl -s -i http://localhost:8080/actuator/health
```

```
HTTP/1.1 200
Content-Type: application/vnd.spring-boot.actuator.v3+json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:43:06 GMT

{"status":"UP","components":{"db":{"status":"UP","details":{"database":"MySQL","validationQuery":"isValid()"}},"diskSpace":{"status":"UP","details":{"total":1967315451904,"free":1001979015168,"threshold":10485760,"path":"/app/.","exists":true}},"ping":{"status":"UP"}}}
```

Λίστα πολιτών:

```bash
curl -s -i http://localhost:8080/citizens
```

```
HTTP/1.1 200
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:43:10 GMT

[]
```

Δημιουργία πολίτη (POST):

```bash
curl -s -i -X POST http://localhost:8080/citizens \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Giorgos","lastName":"Vasiliou","afm":"555666777","amka":"05050512345","birthDate":"1994-05-05"}'
```

```
HTTP/1.1 201
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:43:15 GMT

{"id":1,"firstName":"Giorgos","lastName":"Vasiliou","afm":"555666777","amka":"05050512345","birthDate":"1994-05-05"}
```

Ανάκτηση πολίτη (GET /citizens/1):

```bash
curl -s -i http://localhost:8080/citizens/1
```

```
HTTP/1.1 200
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:43:22 GMT

{"id":1,"firstName":"Giorgos","lastName":"Vasiliou","afm":"555666777","amka":"05050512345","birthDate":"1994-05-05"}
```

Ενημέρωση πολίτη (PUT /citizens/1):

```bash
curl -s -i -X PUT http://localhost:8080/citizens/1 \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Giorgos","lastName":"Vasiliou-Updated","afm":"555666777","amka":"05050512345","birthDate":"1994-05-05"}'
```

```
HTTP/1.1 200
Content-Type: application/json
Transfer-Encoding: chunked
Date: Fri, 23 Jan 2026 18:43:27 GMT

{"id":1,"firstName":"Giorgos","lastName":"Vasiliou-Updated","afm":"555666777","amka":"05050512345","birthDate":"1994-05-05"}
```

Διαγραφή πολίτη (DELETE /citizens/1):

```bash
curl -s -i -X DELETE http://localhost:8080/citizens/1
```

```
HTTP/1.1 204
Date: Fri, 23 Jan 2026 18:43:33 GMT
```

## 8. Υλοποιημένες διορθώσεις

* **Actuator health endpoint:** προστέθηκε το `spring-boot-starter-actuator` στο
  `citizen-service/pom.xml` και εκτίθεται το `/actuator/health`.
* **Σφάλμα `/citizens/{id}` (HTTP 500):** οι controller μέθοδοι πλέον δηλώνουν
  ρητά `@PathVariable("id")`.
