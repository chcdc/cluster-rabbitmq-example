# Cluster RabbitMQ na AWS

Este projeto automatiza a criação e configuração de um cluster RabbitMQ na AWS usando **Terraform** para provisionar a infraestrutura e **Ansible** para configurar os serviços.

## 📋 Visão Geral

O projeto cria um cluster RabbitMQ altamente disponível com:
- **1 nó master** para coordenação do cluster
- **2 nós worker** para distribuição de carga
- **Spot Instances** para redução de custos
- **Configuração automática** do cluster
- **Interface web** do RabbitMQ habilitada

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  RabbitMQ       │    │  RabbitMQ       │    │  RabbitMQ       │
│  Master Node    │◄──►│  Worker Node 1  │◄──►│  Worker Node 2  │
│  (t3.small)     │    │  (t3.small)     │    │  (t3.small)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │    AWS VPC          │
                    │  Security Groups    │
                    │  Multiple Subnets   │
                    └─────────────────────┘
```

## 🚀 Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.0
- **Ansible** >= 2.9
- **AWS CLI** configurado
- **Chave SSH** (`~/.ssh/id_rsa.pub`)

### Configuração AWS
```bash
# Configure suas credenciais AWS
aws configure
```

### Variáveis Obrigatórias
Você precisa definir as seguintes variáveis no Terraform:
- `vpc_id`: ID da VPC onde as instâncias serão criadas
- `subnet_ids`: Lista de IDs das subnets

## 📁 Estrutura do Projeto

```
cluster-rabbitmq-example/
├── terraform/                  # Infraestrutura como código
│   ├── main.tf                # Recursos principais
│   ├── variables.tf           # Variáveis configuráveis
│   ├── outputs.tf             # Outputs do Terraform
│   ├── providers.tf           # Configuração de provedores
│   └── modules/
│       └── spot-instance/     # Módulo para spot instances
├── ansible/                   # Configuração e automação
│   ├── main.yml              # Playbook principal
│   ├── aws_ec2.yml           # Inventário dinâmico AWS
│   ├── ansible.cfg           # Configurações do Ansible
│   ├── group_vars/           # Variáveis por grupo
│   │   └── debian.yml        # Configurações específicas do Debian
│   └── roles/
│       └── rabbitmq/         # Role do RabbitMQ
│           ├── tasks/        # Tarefas de configuração
│           ├── templates/    # Templates de configuração
│           ├── handlers/     # Handlers para restart de serviços
│           └── vars/         # Variáveis do role
└── README.md                 # Este arquivo
```

## 🛠️ Instalação e Uso

### 1. Provisionar Infraestrutura

```bash
cd terraform/

# Inicializar Terraform
terraform init

# Revisar o plano de execução
terraform plan

# Aplicar as mudanças
terraform apply
```

### 2. Configurar Cluster RabbitMQ

```bash
cd ../ansible/

# Verificar inventário de hosts
ansible-inventory -i aws_ec2.yml --graph

# [Opcional] Gerar inventário estático
ansible-playbook -i aws_ec2.yml generate_inventory.yml

# Aplicar configurações do RabbitMQ
ansible-playbook main.yml
```

## ⚙️ Configurações

### Terraform - Variáveis Principais

| Variável | Descrição | Padrão | Obrigatório |
|----------|-----------|--------|-------------|
| `vpc_id` | ID da VPC | - | ✅ |
| `subnet_ids` | Lista de IDs das subnets | - | ✅ |
| `debian_instance_count` | Número de nós worker | 2 | ❌ |
| `debian_instance_master_count` | Número de nós master | 1 | ❌ |
| `debian_instance_type` | Tipo de instância | t3.small | ❌ |
| `spot_price` | Preço máximo spot | 0.016 | ❌ |
| `key_name` | Nome da chave SSH | ssh-key | ❌ |
| `allowed_ssh_cidr` | CIDRs permitidos para SSH | ["0.0.0.0/0"] | ❌ |

### Exemplo de arquivo `terraform.tfvars`:

```hcl
vpc_id = "vpc-12345678"
subnet_ids = ["subnet-12345678", "subnet-87654321"]
debian_instance_count = 2
debian_instance_master_count = 1
spot_price = "0.020"
allowed_ssh_cidr = ["10.0.0.0/8", "172.16.0.0/12"]
```

## 🌐 Acesso ao RabbitMQ

Após a instalação, você pode acessar:

- **Interface Web**: `http://<ip-master>:15672`
- **Usuário padrão**: Configurado pelo Ansible
- **Porta AMQP**: 5672
- **Porta Management**: 15672

## 🔧 Troubleshooting

### Problemas Comuns

**1. Erro de credenciais AWS**
```bash
aws configure list
aws sts get-caller-identity
```

**2. Instâncias spot não disponíveis**
- Aumente o `spot_price` no `variables.tf`
- Considere usar instâncias on-demand

**3. Falha na configuração do cluster**
```bash
# Verificar logs do Ansible
ansible-playbook main.yml -vvv

# Verificar conectividade
ansible all -i aws_ec2.yml -m ping
```

**4. Chave SSH não encontrada**
```bash
# Verificar se a chave existe
ls -la ~/.ssh/id_rsa.pub

# Gerar nova chave se necessário
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

## 🔐 Segurança

### Recomendações de Segurança
- ✅ Use CIDRs específicos em `allowed_ssh_cidr`
- ✅ Configure usuários específicos do RabbitMQ
- ✅ Use SSL/TLS em produção
- ✅ Implemente backup regulares
- ✅ Monitore logs de acesso

### Security Groups
O projeto cria security groups com as seguintes regras:
- **SSH (22)**: Acesso restrito por CIDR
- **RabbitMQ Management (15672)**: Interface web
- **RabbitMQ AMQP (5672)**: Comunicação entre aplicações
- **Tráfego interno**: Comunicação entre nós do cluster

## 📊 Monitoramento

O RabbitMQ Management Plugin é habilitado automaticamente e fornece:
- Dashboard com métricas em tempo real
- Monitoramento de filas
- Gestão de usuários e permissões
- Visualização da topologia do cluster

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request


## 🆘 Suporte

Para problemas e dúvidas:
1. Verifique a seção de [Troubleshooting](#🔧-troubleshooting)
2. Abra uma issue neste repositório

---

**⚠️ Aviso**: Este projeto usa spot instances para reduzir custos, mas elas podem ser interrompidas pela AWS. Para ambientes de produção, considere usar instâncias on-demand ou reserved instances.
