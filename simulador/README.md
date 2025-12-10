# Documentação da Instrução **SQR** – Simple Simulator

## 🖥️ Visão Geral do Simulador

O arquivo `simple_simulator_template.c` implementa um simulador de CPU baseado em **máquina de estados**, reproduzindo o ciclo clássico de instrução:

- 🔍 **Fetch**  
- 🧩 **Decode**  
- ⚙️ **Execute**

---

## ✨ Nova Instrução `SQR Rx`

A instrução `SQR Rx` foi criada para calcular o **quadrado** do valor armazenado em um registrador.

### 📌 Definição


SQR Rx: Rx ← Rx × Rx

Ela pega o valor em `Rx`, multiplica por ele mesmo e armazena o resultado novamente no mesmo registrador.

