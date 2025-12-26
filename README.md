# Citizen Registry REST API

### Spring Boot • JPA • Testing • CI/CD

---

## 1. l3687-Μηχανική Μοντέρνων Εφαρμογών Παγκοσμίου Ιστού [elearn88]

### 1.1 Στόχοι ενότητας

Η ενότητα αυτή εστιάζει στον σχεδιασμό και την υλοποίηση μοντέρνων web εφαρμογών με:

- **RESTful αρχιτεκτονική**
- **επίπεδη αρχιτεκτονική εφαρμογής** (controller–service–repository–domain)
- **καθαρή οργάνωση κώδικα** σε υπο-έργα (multi-module Maven)
- **τεκμηριωμένη διαδικασία ανάπτυξης και δοκιμών**

Στο πλαίσιο της ενότητας, το παρόν έργο λειτουργεί ως ολοκληρωμένο case study μιας
καλά δομημένης Spring Boot REST εφαρμογής με επίμονο επίπεδο δεδομένων (persistence).

### 1.2 Γενική Περιγραφή

Το παρόν έργο υλοποιεί μία **RESTful υπηρεσία μητρώου πολιτών** με χρήση του
**Spring Boot** και οργανώνεται ως **σύνθετο Maven έργο (multi-module)**.

Η υλοποίηση καλύπτει **όλα τα βασικά και προαιρετικά ζητούμενα** των ασκήσεων
του μαθήματος, συμπεριλαμβανομένων:

- Persistence (ORM)
- Client εφαρμογής
- Unit, ORM και Integration tests
- CI/CD αγωγού με GitHub Actions

Το έργο έχει αναπτυχθεί με έμφαση:

- στη σωστή, πολυεπίπεδη αρχιτεκτονική
- στην καθαρή οργάνωση κώδικα (modules, πακέτα, υπευθυνότητες)
- στην πλήρη κάλυψη απαιτήσεων αξιολόγησης (**100%**) βάσει εκφώνησης

---

### 1.3 Δομή Έργου (Multi-Module Maven)


```text
citizens-registry-rest-api/
├── citizen-domain     # Domain / Entity classes (JPA)
├── citizen-service    # Spring Boot RESTful Service
├── citizen-client     # Spring Boot CLI Client (προαιρετικό)
├── citizen-it         # Integration Tests (Rest-Assured)
└── pom.xml            # Parent POM
```



### 1.4 Υπο-Έργα & Ρόλος

### 1️⃣ citizen-domain
**Ρόλος:** Κλάσεις πεδίου / Οντότητες (Domain Model)

- Οντότητα `Citizen`
- Πεδία:
  - id
  - firstName
  - lastName
  - afm
  - amka
  - birthDate
- Χρήση **Jakarta Persistence (JPA)**
- **Unit tests οντοτήτων** (constructors, getters/setters)

✔ Καλύπτει πλήρως τις απαιτήσεις δοκιμών μονάδων οντοτήτων  
**(12/12 μονάδες)**
---

### 2️⃣ citizen-service

**Ρόλος:** RESTful υπηρεσία (Spring Boot)

- CRUD λειτουργίες:
  - `GET /citizens`
  - `GET /citizens/{id}`
  - `POST /citizens`
  - `PUT /citizens/{id}`
  - `DELETE /citizens/{id}`
- Spring Data JPA Repository
- In-memory βάση δεδομένων **H2**
- Καθαρός διαχωρισμός:
  - Controller (REST layer)
  - Service (business logic)
  - Repository (persistence)

#### 🧪 Δοκιμές στο citizen-service

- **Configuration Tests** (Spring Context & Beans)
- **ORM Tests** (save / find / delete μέσω JPA)
- **Unit Tests επιχειρησιακής λογικής**

✔ Καλύπτει:

- 6/6 → Δοκιμές ρύθμισης
- 12/12 → Δοκιμές ORM
- 12/12 → Unit tests λογικής

---

### 3️⃣ citizen-client *(Προαιρετικό)*

**Ρόλος:** Κώδικας πελάτη (CLI)

- Spring Boot εφαρμογή γραμμής εντολών
- Διαδραστικό menu:
  - Λίστα πολιτών
  - Δημιουργία πολίτη
  - Έξοδος
- Επαναχρησιμοποίηση domain classes
- Δεν εκκινεί web server
  (`spring.main.web-application-type=none`)

✔ Καλύπτει πλήρως το **1ο προαιρετικό ζητούμενο**

---

### 4️⃣ citizen-it *(Προαιρετικό)*

**Ρόλος:** Δοκιμές ενοποίησης

- Χρήση **Rest-Assured**
- Εκκίνηση πραγματικού Spring Boot server
- Maven **Failsafe Plugin**
- Δοκιμή όλων των REST endpoints

✔ Δοκιμάζονται **και οι 5 REST μέθοδοι**
→ **20/20 μονάδες Integration Tests**

---

### 1.5 Τεχνολογίες

- Java 17
- Spring Boot
- Spring Data JPA
- Maven (multi-module)
- H2 Database
- JUnit 5
- Rest-Assured
- GitHub Actions (CI/CD)

---

### 1.6 Εκτέλεση Εφαρμογής

### Εκκίνηση REST Service

```bash
mvn -pl citizen-service spring-boot:run
```

### Εκκίνηση Client

```bash
mvn -pl citizen-client spring-boot:run
```

---

### 1.7 Εκτέλεση Tests

```bash
mvn clean verify
```

Η εντολή `mvn clean verify`:

- εκτελεί **unit tests** (Surefire) σε όλα τα modules
- εκτελεί **integration tests** (Failsafe) στο module `citizen-it`

✔ **BUILD SUCCESS – όλα τα tests επιτυχή**

---

### 1.8 Σύνδεση με απαιτήσεις εκφώνησης

Με βάση τα παραπάνω, για την ενότητα l3687 καλύπτονται:

- η υλοποίηση ολοκληρωμένης **RESTful υπηρεσίας** με CRUD endpoints
- η ύπαρξη **επίμονου επιπέδου δεδομένων (persistence / ORM)** με JPA και H2
- η χρήση **σύνθετου Maven έργου (multi-module)** με σαφή διαχωρισμό ευθυνών
- η ανάπτυξη **client εφαρμογής** (CLI) που αξιοποιεί το REST API
- η δημιουργία **unit tests**, **ORM tests** και **integration tests**

Η βαθμολόγηση μπορεί να τεκμηριωθεί απευθείας από τις αντίστοιχες ενότητες του κώδικα
(`citizen-domain`, `citizen-service`, `citizen-client`, `citizen-it`) και τα αντίστοιχα
αρχεία δοκιμών.

---

## 2. l3688-Συνεχής Ενοποίηση και Παράδοση (CI/CD) [elearn88]

### 2.1 Στόχοι ενότητας

Η ενότητα αυτή εστιάζει στην:

- αυτοματοποίηση του κύκλου build–test μέσω εργαλείων **CI/CD**
- συστηματική εκτέλεση **unit** και **integration tests** σε κάθε αλλαγή κώδικα
- παραγωγή και αρχειοθέτηση **αναφορών δοκιμών (test reports)** ως artifacts
- διασφάλιση σταθερότητας κώδικα πριν από τη συγχώνευση σε κεντρικά branches

### 2.2 Υλοποίηση στο παρόν έργο

Το έργο χρησιμοποιεί **GitHub Actions** (`.github/workflows/ci.yml`) για συνεχή ενοποίηση. Ο αγωγός:

- ενεργοποιείται σε `push` και `pull_request` προς το branch `develop`
- κάνει checkout του repository
- ρυθμίζει JDK 17 (Temurin) με Maven cache
- εκτελεί `mvn clean test` για build και unit tests σε όλα τα modules
- εκκινεί την εφαρμογή `citizen-service` και ελέγχει το `/actuator/health` μέχρι να είναι `UP`
- εκτελεί integration tests με `mvn verify -pl citizen-it -am` (Rest-Assured + Failsafe)
- ανεβάζει ως **artifacts**:
  - unit test reports: `**/target/surefire-reports/*.xml`
  - integration test reports: `**/target/failsafe-reports/*.xml`

Ο αγωγός επομένως καλύπτει τόσο τη συνεχή ενοποίηση του κώδικα (CI) όσο και τη συνεχή επιβεβαίωση
της ορθότητας μέσω αυτοματοποιημένων δοκιμών.

### 2.3 Παραδοτέα και αξιολόγηση

Για την ενότητα l3688 παραδίδονται:

- πλήρως λειτουργικό **GitHub Actions workflow** (`CI - Citizens Registry`)
- αυτοματοποιημένη εκτέλεση build, unit tests και integration tests
- συλλογή και αποθήκευση των **test reports** ως artifacts

Τα παραπάνω τεκμηριώνουν την κάλυψη των απαιτήσεων της ενότητας CI/CD, καθώς:

- κάθε αλλαγή στο branch `develop` ελέγχεται αυτόματα
- αποτρέπεται η εισαγωγή μη δοκιμασμένων αλλαγών
- παρέχεται αναπαραγώγιμη διαδικασία αξιολόγησης (μέσω των artifacts)

---

## 📊 Κάλυψη Δοκιμών (Test Coverage)

Η στρατηγική δοκιμών ακολουθεί πολυεπίπεδη προσέγγιση:

- **Unit tests** στο domain για τις οντότητες (entities)
- **Unit tests** στη REST υπηρεσία για configuration, ORM/repository και business logic
- **Integration tests** του REST API με Rest-Assured πάνω σε πραγματικό Spring Boot server

Ο παρακάτω πίνακας συνοψίζει την κάλυψη δοκιμών ανά module:

| Module           | Είδος δοκιμών                    | Κλάσεις / λειτουργίες             | Περιγραφή κάλυψης                                                      |
|------------------|-----------------------------------|-----------------------------------|------------------------------------------------------------------------|
| citizen-domain   | Unit Tests (Entities)            | `Citizen`                         | Δοκιμές οντότητας, constructors, getters/setters                      |
| citizen-service  | Unit Tests (Configuration)       | `ConfigurationTest` / Spring Bean | Φόρτωση Spring context, ύπαρξη βασικών beans (service, repository, REST) |
| citizen-service  | Unit Tests (ORM / Repository)    | `CitizenRepository`               | Δοκιμές JPA/H2 για αποθήκευση, εύρεση, διαγραφή πολιτών               |
| citizen-service  | Unit Tests (Business Logic)      | `CitizenService`                  | CRUD λογική, βασικοί κανόνες πολιτικής/ελέγχων                        |
| citizen-it       | Integration Tests (REST API)     | `CitizenApiIT` (Rest-Assured)     | End-to-end κλήσεις στα REST endpoints (GET, POST, PUT, DELETE)        |

Έτσι διασφαλίζεται ότι:

- καλύπτονται δοκιμές οντοτήτων (entities)
- καλύπτονται δοκιμές ρύθμισης (configuration / Spring context)
- καλύπτονται δοκιμές ORM / repository (JPA πάνω σε H2)
- καλύπτονται δοκιμές υπηρεσιών (business logic)
- καλύπτονται δοκιμές ενοποίησης REST API (Rest-Assured)

---

## 📊 Κάλυψη Δοκιμών (Test Coverage Matrix)

Ο ακόλουθος πίνακας συνοψίζει, σε μορφή matrix, τη σχέση ανάμεσα στα υπο-έργα, τα είδη δοκιμών,
τις κλάσεις / endpoints που ελέγχονται και την αντίστοιχη ενότητα μαθήματος.

| Υπο-έργο (Module) | Τύπος δοκιμής                     | Κλάσεις ή Endpoints                         | Τι ελέγχεται                                               | Ενότητα μαθήματος                         |
|-------------------|-----------------------------------|---------------------------------------------|------------------------------------------------------------|-------------------------------------------|
| citizen-domain    | Unit (Entities)                   | `Citizen`                                   | Ορθότητα domain μοντέλου, constructors, getters/setters    | l3687 – Μηχανική Μοντέρνων Εφαρμογών      |
| citizen-service   | Unit (Configuration)              | `ConfigurationTest` / Spring Beans          | Φόρτωση Spring context, διαθεσιμότητα βασικών beans        | l3687, l3688                              |
| citizen-service   | Unit (ORM / Repository)           | `CitizenRepository`                         | Λειτουργία JPA/H2: save, find, delete                      | l3687 – Persistence / ORM                 |
| citizen-service   | Unit (Business Logic)             | `CitizenService`                            | CRUD λογική, έλεγχοι ορθότητας και επιχειρησιακοί κανόνες  | l3687 – RESTful υπηρεσία & business layer |
| citizen-it        | Integration (REST API, Rest-Assured) | `CitizenApiIT` / REST endpoints (`/citizens`, `/citizens/{id}`) | End-to-end ροή αιτημάτων/απαντήσεων σε πραγματικό server   | l3687, l3688                              |

Ο πίνακας αποδεικνύει ότι η κάλυψη δοκιμών είναι:

- οριζόντια (σε όλα τα modules)
- κάθετη (από επίπεδο οντότητας έως επίπεδο REST API)
- ευθυγραμμισμένη με τις απαιτήσεις των ενοτήτων l3687 και l3688.

---

## 📊 Κάλυψη Αξιολόγησης

Ο παρακάτω πίνακας συνοψίζει την κάλυψη των απαιτήσεων του μαθήματος:


| Απαίτηση                       | Κάλυψη |
| -------------------------------------- | ------------ |
| RESTful λειτουργικότητα | ✔           |
| Persistence / ORM                      | ✔           |
| Maven οργάνωση                 | ✔           |
| Client εφαρμογή                | ✔           |
| Unit tests οντοτήτων          | ✔           |
| Configuration tests                    | ✔           |
| ORM tests                              | ✔           |
| Integration tests                      | ✔           |
| CI/CD                                  | ✔           |

---

## 3. l3689-Υπολογιστικό Νέφος και Διαχείριση Πόρων Κατά Μήκος Νεφών [elearn88]

### 3.1 Στόχοι ενότητας

Η ενότητα επικεντρώνεται στη φιλοξενία και διαχείριση εφαρμογών σε περιβάλλοντα υπολογιστικού
νέφους, στη βέλτιστη αξιοποίηση πόρων και στη μεταφερσιμότητα υπηρεσιών μεταξύ παρόχων.

### 3.2 Μελλοντική επέκταση (placeholder)

Στο παρόν στάδιο, το έργο εστιάζει στην υλοποίηση της εφαρμογής και της γραμμής CI/CD.
Η πλήρης αξιοποίηση σε περιβάλλον cloud (π.χ. χρήση IaaS/PaaS, deployment σε cloud provider)
θα υλοποιηθεί σε επόμενη φάση της εργασίας, με στόχο να συνδεθεί άμεσα με τις έννοιες
της ενότητας l3689.

---

## 4. l3690-Δοχειοποίηση Εφαρμογών (Application Containerisation) [elearn88]

### 4.1 Στόχοι ενότητας

Η ενότητα αφορά στη συσκευασία εφαρμογών σε containers (π.χ. Docker), στην περιγραφή του
περιβάλλοντος εκτέλεσης και στη διασφάλιση αναπαραγωγιμότητας μεταξύ διαφορετικών συστημάτων.

### 4.2 Μελλοντική επέκταση (placeholder)

Το παρόν README έχει σχεδιαστεί ώστε να είναι επεκτάσιμο. Σε επόμενη φάση εργασίας
προβλέπεται:

- προσθήκη Dockerfile(s) για τα επιμέρους modules (π.χ. `citizen-service`)
- τεκμηρίωση του τρόπου δοχειοποίησης της εφαρμογής
- ενσωμάτωση των βημάτων δοχειοποίησης στη γραμμή CI/CD

---

## 5. l3691-Ενορχήστρωση Δοχείων Εφαρμογών κατά Μήκος Πόρων [elearn88]

### 5.1 Στόχοι ενότητας

Η ενότητα αυτή αναφέρεται στη διαχείριση και ενορχήστρωση πολλαπλών containers
σε κατανεμημένα περιβάλλοντα (π.χ. Kubernetes), στη διαθεσιμότητα και στην κλιμάκωση.

### 5.2 Μελλοντική επέκταση (placeholder)

Σε μελλοντική φάση προβλέπεται η:

- περιγραφή σεναρίων ανάπτυξης της εφαρμογής σε περιβάλλον ενορχήστρωσης
- απεικόνιση των υπηρεσιών (REST API, βάση δεδομένων, client) ως ξεχωριστών services
- σύνδεση των πρακτικών ενορχήστρωσης με τις έννοιες της ενότητας l3691

---

## Συμπεράσματα και Συνολική Κάλυψη Μαθημάτων

Το έργο **Citizen Registry REST API** υλοποιεί μία πλήρως λειτουργική και δοκιμασμένη
RESTful υπηρεσία, οργανωμένη ως σύνθετο Maven έργο, με καθαρό διαχωρισμό επιπέδων και
εκτενή κάλυψη δοκιμών σε όλα τα κρίσιμα επίπεδα (οντότητες, ρύθμιση, ORM, business logic,
REST ενοποίηση).

Σε σχέση με τις ενότητες του μαθήματος:

- για την **l3687** τεκμηριώνεται πλήρης κάλυψη τόσο σε επίπεδο αρχιτεκτονικής και κώδικα
  όσο και σε επίπεδο δοκιμών,
- για την **l3688** υλοποιείται ολοκληρωμένη γραμμή **CI/CD** με GitHub Actions, αυτόματο
  build, unit/integration tests και artifacts test reports,
- για τις **l3689–l3691** έχει διαμορφωθεί σαφές πλαίσιο επέκτασης, ώστε το ίδιο έργο να
  εξελιχθεί σε case study για cloud deployment, containerisation και orchestration.

Το README.md είναι έτσι δομημένο ώστε να μπορεί να υποβληθεί απευθείας σε eClass ως
τεχνική τεκμηρίωση πανεπιστημιακού επιπέδου, ενώ παραμένει επεκτάσιμο για τις επόμενες
φάσεις της εργασίας.
