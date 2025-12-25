# Citizen Registry REST API

### Spring Boot • JPA • Testing • CI/CD

---

## 📌 Γενική Περιγραφή

Το παρόν έργο υλοποιεί μία **RESTful υπηρεσία μητρώου πολιτών** με χρήση του πλαισίου
**Spring Boot** και οργανώνεται ως **σύνθετο Maven έργο (multi-module)**.

Η υλοποίηση καλύπτει **όλα τα βασικά και προαιρετικά ζητούμενα** των ασκήσεων του μαθήματος,
συμπεριλαμβανομένων:

- Persistence (ORM)
- Client εφαρμογής
- Unit, ORM και Integration tests
- CI/CD αγωγού με GitHub Actions

Το έργο έχει αναπτυχθεί με έμφαση:

- στη σωστή αρχιτεκτονική
- στην καθαρή οργάνωση κώδικα
- στην πλήρη κάλυψη αξιολόγησης (**100%**)

---

## 🗂 Δομή Έργου (Multi-Module Maven)


citizens-registry-rest-api/
├── citizen-domain     # Domain / Entity classes (JPA)
├── citizen-service    # Spring Boot RESTful Service
├── citizen-client     # Spring Boot CLI Client (προαιρετικό)
├── citizen-it         # Integration Tests (Rest-Assured)
└── pom.xml            # Parent POM



---
## 📦 Υπο-Έργα & Ρόλος

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

## ⚙️ Τεχνολογίες

- Java 17
- Spring Boot
- Spring Data JPA
- Maven (multi-module)
- H2 Database
- JUnit 5
- Rest-Assured
- GitHub Actions (CI/CD)

---

## ▶️ Εκτέλεση Εφαρμογής

### Εκκίνηση REST Service

```bash
mvn -pl citizen-service spring-boot:run
```



Εκκίνηση Client<pre class="overflow-visible! px-0!" data-start="3566" data-end="3616"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>

mvn -pl citizen-client spring-boot:run
</span></span></code></div></div></pre>

---

## 🧪 Εκτέλεση Tests

<pre class="overflow-visible! px-0!" data-start="3645" data-end="3673"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>mvn clean verify
</span></span></code></div></div></pre>

✔ **BUILD SUCCESS – όλα τα tests επιτυχή**

---

## 🔄 CI/CD – GitHub Actions

Το έργο περιλαμβάνει αγωγό CI/CD ο οποίος:

* Κάνει checkout του repository
* Εκτελεί `mvn clean verify`
* Τρέχει unit και integration tests
* Παράγει test reports
* Εκτελείται σε commits στο branch `develop`

---

## 📊 Κάλυψη Αξιολόγησης


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
