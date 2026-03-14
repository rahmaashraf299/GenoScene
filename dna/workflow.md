# GenoScene: Forensic DNA Phenotyping System 🧬

### 📋 Project Overview
The **GenoScene** project aims to develop an advanced system for predicting phenotypic traits—such as **eye color, hair color, and skin color**—through rigorous DNA analysis (DNA Phenotyping). By integrating computational science with genetics, the system processes genetic markers (**SNPs**) using advanced bioinformatics tools to transform raw data into accurate, scientifically validated physical profiles.

### 🎯 Project Goals
* **Advanced Identity Inference:** Supporting law enforcement and research institutions with innovative tools for forensic investigations.
* **Interdisciplinary Integration:** Bridging the gap between genomic data processing and practical forensic applications.
* **Reliable Predictions:** Applying statistical, machine learning, and deep learning techniques to enhance the precision and interpretability of genetic predictions.




-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

## 🚀 Key Features & Project Workflow

### 🧬 1. Precision DNA Phenotyping
The core of **GenoScene** is its ability to reconstruct a visual profile from genetic data.
* **Target Traits:** The system accurately predicts:
    * **Eye Color:** (e.g., Brown, Blue, Green).
    * **Hair Color:** (e.g., Black, Blond, Brown, Red).
    * **Skin Tone:** (e.g., Light, Medium, Dark).
* **From SNPs to Traits:** We analyze specific **SNPs (Single Nucleotide Polymorphisms)** which are the most common type of genetic variation. Our AI models identify the "Genotype" at specific loci and map them to the corresponding "Phenotype" using patterns learned from massive forensic datasets.


                              -------------------------------------



### 📱 2. Mobile Application Architecture (Flutter)
The **GenoScene** mobile application is built using **Flutter**, ensuring a smooth and responsive experience. Below is the detailed breakdown of the app's architecture and screens:

### 🌟 1. Onboarding & Authentication
* **Onboarding Experience:** A series of interactive screens that introduce users to the concept of **DNA Phenotyping** and how the app assists in forensic profile reconstruction.
* **Secure Access (Login/Register):** A robust authentication system to ensure that sensitive genetic data is handled securely, providing personal accounts for each researcher or investigator.

### 🏠 2. Dynamic Home Dashboard
* **Central Hub:** The Home screen acts as a navigation center, providing a quick overview of the project’s mission, recent activities, and quick access to the main tools (Upload, Analysis, and Learning).

### 📁 3. DNA Data Upload Center
* **File Upload:** A dedicated module where users can upload their DNA sequence files (supporting specific formats used in genomic research).
* **Validation & Requirements:** This screen clearly outlines the "File Standards" needed for the AI to work correctly, such as specific SNP columns or file extensions, ensuring high-quality input for the models.

### 🧪 4. AI-Driven Analysis & Results
* **Predictive Engine:** Once the file is processed, this section displays the results of the **DNA Phenotyping**.
* **Detailed Analytics:** Traits are not just shown as text; they are presented with **Confidence Percentages** for each trait (e.g., "95% probability of Brown Eyes"), giving a scientific weight to the predictions.

### 📚 5. Educational Learning Hub
* **Multimedia Content:** A rich library of educational resources including **Videos**, **Images**, and **Articles**.
* **Genetic Insights:** Deep dives into the specific "Influential Genes" and how they affect physical traits, helping users understand the biology behind the AI.

### 👤 6. User Profile & Settings
* **Profile Management:** Allows users to edit their personal information and preferences.
* **Support & Privacy:** Includes dedicated sections for **Privacy Policy**, **Contact Us** for technical support, and a secure **Logout** function.
                            
### 📚 3. Integrated Learning Section (The Forensic Hub)
Because **GenoScene** aims to spread knowledge as well as provide tools:
* **Interactive Lessons:** Explaining the basics of DNA, Genotypes vs. Phenotypes, and how SNPs influence our appearance.
* **Forensic Awareness:** A dedicated section to show the importance of DNA Phenotyping in solving "Cold Cases" and identifying unknown remains.



                                       ----------------------------------



### 🧠 4. Advanced AI & Model Engineering
Our AI architecture is built on a "Specialized Modeling" approach to ensure maximum prediction accuracy for each physical trait.

* **Optimized Feature Selection:** We identified and utilized the most influential **SNPs (e.g., 13, 35, 35)** as primary predictors, reducing noise and improving model focus.
* **Multi-Model Pipeline:** Unlike standard approaches, we trained **dedicated models for each individual trait** (Eye, Hair, Skin).
* **Algorithm Benchmarking:** We implemented and compared a wide range of state-of-the-art algorithms:
    * **Boosting Models:** XGBoost, LightGBM, and HistGradientBoosting.
    * **Bagging & Traditional:** Random Forest and Logistic Regression.
    * **Deep Learning for Tabular Data:** TabNet.
* **Automated Model Selection:** We developed a custom **Selection Function** that automatically evaluates and chooses the "Best Performing Model" for each specific trait based on validation metrics.
* **Evaluation Metrics:** Every model is rigorously tested using Accuracy, Confusion Matrices, and Log Loss to ensure reliable forensic-grade results.




----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------



##  Business Model & Target Audience

To ensure **GenoScene** operates as a sustainable and scalable venture, we have identified key market sectors and a diversified revenue model.

### 🎯 Our Target Clients
* **Law Enforcement & Disaster Recovery Units:** Primary partners for solving complex criminal cases and rapid victim identification in mass casualty events.
* **Forensic Laboratories & Research Centers:** Institutions utilizing our technology to enhance DNA analysis efficiency and achieve high-precision results in record time.

### 💰 Revenue Streams & Sustainability
Our financial model is designed to balance stability with market growth:
* **Governmental Annual Subscriptions:** Provides a stable, recurring revenue base from large-scale entities like police departments and national labs, ensuring long-term development.
* **Pay-Per-Report (Flexible Model):** Offers an "on-demand" service for individual researchers or specific small-scale cases, ensuring healthy cash flow and market flexibility.

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

## 🛠️ Tech Stack & Tools

The development of **GenoScene** involved a diverse set of technologies to handle complex genetic data and provide a seamless mobile experience.

### 📱 Mobile Development
* **Framework:** Flutter (Dart).
* **State Management:** [Mention if you use Provider, Bloc, or GetX].
* **Architecture:** Clean Architecture for scalable mobile components.
                            ------------------------------

### 🧠 Data Science & AI Engine
* **Language:** Python (for model training and evaluation).
* **Machine Learning Libraries:** Scikit-learn, XGBoost, LightGBM, HistGradientBoosting.
* **Deep Learning:** TabNet (for tabular genetic data).
* **Data Manipulation:** Pandas & NumPy.
* **Evaluation:** Confusion Matrix, Log Loss, and Accuracy metrics.
                           --------------------------------

### 🌐 Backend & Infrastructure
To ensure a secure and scalable environment, we developed a comprehensive backend system:
* **Web Framework:** Django / Python (Django REST Framework).
* **Security & Auth:** Full JWT (JSON Web Token) authentication system for secure user access.
* **Database:** Relational Database to store User History, DNA Samples, and Generated Results.
* **Integrations:** Airforce API for AI face image generation based on predicted traits.
* **Architecture:** Token-based protected endpoints with `IsAuthenticated` permissions.

                          -------------------------------
### 🔧 Development Environment
* **IDE:** VS Code & Android Studio.
* **Version Control:** Git & GitHub.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## 🌐 Backend Architecture & API Ecosystem

The **GenoScene** backend is a fully integrated ecosystem that manages the entire lifecycle from DNA upload to visual reconstruction.

### 🔐 Security & Identity
* **JWT Authentication:** Every request is secured using Token-based authentication, ensuring that DNA data and analysis history are private and linked to specific user accounts.
* **Permission Layers:** All endpoints are protected with `IsAuthenticated` classes to prevent unauthorized access.
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

### 📡 API Reference (Technical Endpoints)

1. **Analysis Engine:** `/api/analyze/` [POST]
   - **Action:** Receives the CSV (DNA sample), stores it, and triggers the trait-specific AI models.
   - **Output:** Returns probabilities for Eye, Hair, and Skin colors, along with a summary and confidence scores.
   - **Storage:** Automatically saves results into `Analysis` (JSON) and `Prediction` (Final scores) tables.

2. **Visual Reconstruction:** `/api/generate-face/` [POST]
   - **Action:** Takes predicted traits and `analysis_id` to generate a facial profile via **Airforce API**.
   - **Persistence:** Saves the generated image URL in the `GeneratedFace` records.

3. **User Intelligence:** - `/api/analysis-history/`: Retrieves the user’s full history of DNA analyses and generated images.
   - `/api/model-logs/`: Provides a detailed log of operations for debugging and system monitoring.

### 🔄 Integrated Workflow (The Pipeline)
1. **Upload:** User uploads a CSV file through the **Flutter** app.
2. **AI Processing:** The backend extracts the **13 key SNPs** and runs the specialized models.
3. **Storage & Feedback:** Results are stored in the database, and the user receives a detailed analysis report.
4. **Visualization:** The system calls the **Airforce API** to generate a visual representation based on the prediction.
5. **History:** All steps are logged and stored for future reference and forensic auditing.