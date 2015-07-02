class Doctor < ActiveRecord::Base
  has_many :patients
  has_many :invoices
  has_many :appointments
  has_many :treatment_plans
  has_many :prescriptions
  has_many :prescription_templates
  has_many :prescription_layouts
  has_many :custom_form_templates
  has_many :tag_templates
  has_many :custom_procedures
  has_many :lazy_texts

  has_one :profile, dependent: :destroy
  before_create :build_default_profile
  after_create :auto_setup_models

  acts_as_role

  delegate :first_name, :name_with_title, :first_name_with_title, to: :user

  def council
    council_str = Profession.council(profession_code)
    council_str.present? ? council_str : 'Conselho profissional'
  end

  def default_procedure
    custom_procedures.default.first
  end

  def default_custom_form_template(type)
    if type == 1 # Anamnese Clovis
      delete_anamnesis
      # custom_form_templates.create( name: "Anamnese",
      #   notes: "Queixa principal: \r\n\r\nHistória da doença atual: \r\n\r\nRevisão de sistemas: \r\n\r\nHistória patológica pregressa: \r\n.comorbidades: \r\n( ) Depressão/Ansiedade\r\n( ) Coronariopatia\r\n( ) Valvopatia\r\n( ) Diabetes\r\n( ) HAS\r\n( ) Alergias\r\n( ) Cirurgias Prévias\r\n( ) Convulsões\r\n( ) Doenças Congênitas\r\n( ) Hip/Hipertiroidismo\r\n( ) Internações Prévias\r\n( ) Neoplasias\r\n( ) Neuropatias\r\n( ) Nefropatias\r\n( ) Osteopatias\r\n( ) Pneumopatias\r\n( ) Transfusão Prévias\r\n.medicação em uso: \r\n.alergias: \r\n.cirurgias prévias: \r\n.internações hospitalares: \r\n.antecedentes ginecológico e obstétrico\r\n.vacinação : \r\n.exames preventivos: \r\n\r\nHistória familiar: \r\n( ) AVC\r\n( ) DAC\r\n( ) DM\r\n( ) Doenças Genéticas\r\n( ) HAS\r\n( ) Neoplasia\r\n( ) Obesidade\r\n.Outras: \r\n\r\nHistória social e hábitos de vida: \r\n\r\nExame físico: \r\n.Peso: \r\n.Altura: \r\n.IMC: \r\n.CA: \r\n.Estado geral: \r\n.Oroscopia: \r\n.Otoscopia: \r\n.Aparelho cardiovascular: \r\n.Pulsos: \r\n.Ritmo: \r\n.FC: \r\n.PA decúbito: \r\n.PA sentado: \r\n.PA ortostatico: \r\n\r\nAparelho respiratório: \r\n.Fr: \r\n.Sat: \r\n.Aparelho digestivo: \r\n.Membros inferiores e superiores: \r\n\r\nExames: \r\n\r\nHipótese diagnóstica: \r\n\r\nConduta: " )
      template = custom_form_templates.create( name: 'Anamnese', anamnesis: true )
      template.fields.create( position: 1, field_type: "text_field", field_label: "Queixa principal", field_unit: "", field_values: "" )
      template.fields.create( position: 2, field_type: "text_area", field_label: "História da doença atual", field_unit: "", field_values: "" )
      template.fields.create( position: 3, field_type: "text_area", field_label: "Revisão de sistemas", field_unit: "", field_values: "" )
      template.fields.create( position: 4, field_type: "header", field_label: "História patológica pregressa", field_unit: "", field_values: "" )
      template.fields.create( position: 5, field_type: "check_box", field_label: "Comorbidades", field_unit: "",
        field_values: "Depressão/Ansiedade\r
Coronariopatia\r
Valvopatia\r
Diabetes\r
HAS\r
Alergias\r
Cirurgias Prévias\r
Convulsões\r
Doenças Congênitas\r
Hip/Hipertiroidismo\r
Internações Prévias\r
Neoplasias\r
Neuropatias\r
Nefropatias\r
Osteopatias\r
Pneumopatias\r
Transfusão Prévias\r" )
      template.fields.create( position: 6, field_type: "text_field", field_label: "medicação em uso", field_unit: "", field_values: "" )
      template.fields.create( position: 7, field_type: "text_field", field_label: "alergias", field_unit: "", field_values: "" )
      template.fields.create( position: 8, field_type: "text_field", field_label: "cirurgias prévias", field_unit: "", field_values: "" )
      template.fields.create( position: 9, field_type: "text_field", field_label: "internações hospitalares", field_unit: "", field_values: "" )
      template.fields.create( position: 10, field_type: "text_field", field_label: "antecedentes ginecológico e obstétrico", field_unit: "", field_values: "" )
      template.fields.create( position: 11, field_type: "text_field", field_label: "vacinação", field_unit: "", field_values: "" )
      template.fields.create( position: 12, field_type: "text_field", field_label: "exames preventivos", field_unit: "", field_values: "" )
      template.fields.create( position: 13, field_type: "check_box", field_label: "História familiar", field_unit: "",
        field_values: "AVC\r
DAC\r
DM\r
Doenças Genéticas\r
HAS\r
Neoplasia\r
Obesidade\r" )
      template.fields.create( position: 14, field_type: "text_field", field_label: "Outras", field_unit: "", field_values: "" )

      template.fields.create( position: 15, field_type: "text_area", field_label: "História social e hábitos de vida", field_unit: "", field_values: "" )

      template.fields.create( position: 16, field_type: "header", field_label: "Exame físico", field_unit: "", field_values: "" )
      template.fields.create( position: 17, field_type: "number_field", field_label: "Peso", field_unit: "Kg", field_values: "" )
      template.fields.create( position: 18, field_type: "number_field", field_label: "Altura", field_unit: "m", field_values: "" )
      template.fields.create( position: 19, field_type: "number_field", field_label: "IMC", field_unit: "Kg/m2", field_values: "" )
      template.fields.create( position: 20, field_type: "text_field", field_label: "CA", field_unit: "", field_values: "" )
      template.fields.create( position: 21, field_type: "text_field", field_label: "Estado geral", field_unit: "", field_values: "" )
      template.fields.create( position: 22, field_type: "text_field", field_label: "Oroscopia", field_unit: "", field_values: "" )
      template.fields.create( position: 23, field_type: "text_field", field_label: "Otoscopia", field_unit: "", field_values: "" )
      template.fields.create( position: 24, field_type: "text_field", field_label: "Aparelho cardiovascular", field_unit: "", field_values: "" )
      template.fields.create( position: 25, field_type: "number_field", field_label: "Pulsos", field_unit: "bpm", field_values: "" )
      template.fields.create( position: 26, field_type: "number_field", field_label: "Ritmo", field_unit: "bpm", field_values: "" )
      template.fields.create( position: 27, field_type: "text_field", field_label: "FC", field_unit: "", field_values: "" )
      template.fields.create( position: 28, field_type: "number_field", field_label: "PA decúbito", field_unit: "mmHg", field_values: "" )
      template.fields.create( position: 29, field_type: "number_field", field_label: "PA sentado", field_unit: "mmHg", field_values: "" )
      template.fields.create( position: 30, field_type: "number_field", field_label: "PA ortostatico", field_unit: "mmHg", field_values: "" )

      template.fields.create( position: 31, field_type: "header", field_label: "Aparelho respiratório", field_unit: "", field_values: "" )
      template.fields.create( position: 32, field_type: "number_field", field_label: "FR", field_unit: "rpm", field_values: "" )
      template.fields.create( position: 33, field_type: "number_field", field_label: "Sat", field_unit: "%", field_values: "" )
      template.fields.create( position: 34, field_type: "text_field", field_label: "Aparelho digestivo", field_unit: "", field_values: "" )
      template.fields.create( position: 35, field_type: "text_field", field_label: "Membros inferiores e superiores", field_unit: "", field_values: "" )

      template.fields.create( position: 36, field_type: "text_area", field_label: "Exames", field_unit: "", field_values: "" )
      template.fields.create( position: 37, field_type: "text_area", field_label: "Hipótese diagnóstica", field_unit: "", field_values: "" )
      template.fields.create( position: 38, field_type: "text_area", field_label: "Conduta", field_unit: "", field_values: "" )
      logger.info "Template created: Anamnese Clovis"

    elsif type == 2 # Risco Cirúrgico
      # custom_form_templates.create( name: "Risco Cirúrgico",
      # notes: ">>> Identificação\r\n\r\nNome: \r\nData nasc: \r\nProfissão: \r\nIdade: \r\nsexo: \r\nNatural: \r\n\r\nTipo de Cirurgia / Anestesia: \r\n\r\nComorbidades: \r\n\r\nSintomas cardiovasculares: \r\n\r\nMedicação em uso: \r\n\r\nAlergias: \r\n\r\nAntecedentes cirúrgicos: \r\n\r\nAntecedentes anestésicos: \r\n\r\nCapacidade funcional: \r\n\r\n\r\n>>> Exame físico\r\n\r\nPeso: kg\r\nAltura:  cm\r\nIMC: \r\nACV: \r\nFC: \r\nPA: \r\nAparelho respiratório: \r\nSat: \r\nABDM: \r\nMMIISS: \r\n\r\n\r\n>>> Exames laboratoriais\r\n\r\nECG: \r\nFC: \r\nRX: \r\nHT e HB: \r\nCoagulograma: \r\nCreatinina:  mg/dl\r\nOutros: \r\nECO: \r\nECG: \r\n\r\n>>> Risco: \r\n\r\n\r\n>>> Recomendações: \r\n")
      template = custom_form_templates.create( name: 'Risco Cirúrgico' )
      template.fields.create( position: 1, field_type: "text_field", field_label: "Tipo de Cirurgia/Anestesia", field_unit: "", field_values: "" )
      template.fields.create( position: 2, field_type: "text_field", field_label: "Comorbidades", field_unit: "", field_values: "" )
      template.fields.create( position: 3, field_type: "text_field", field_label: "Sintomas cardiovasculares", field_unit: "", field_values: "" )
      template.fields.create( position: 4, field_type: "text_field", field_label: "Medicação em uso", field_unit: "", field_values: "" )
      template.fields.create( position: 5, field_type: "text_field", field_label: "Alergias", field_unit: "", field_values: "" )
      template.fields.create( position: 6, field_type: "text_field", field_label: "Antecedentes cirurgicos", field_unit: "", field_values: "" )
      template.fields.create( position: 7, field_type: "text_field", field_label: "Antecedentes anestésicos", field_unit: "", field_values: "" )
      template.fields.create( position: 8, field_type: "text_field", field_label: "Capacidade funcional", field_unit: "", field_values: "" )
      template.fields.create( position: 9, field_type: "header", field_label: "Exame Físico", field_unit: "", field_values: "" )
      template.fields.create( position: 10, field_type: "number_field", field_label: "Peso", field_unit: "kg", field_values: "" )
      template.fields.create( position: 11, field_type: "number_field", field_label: "Altura", field_unit: "m", field_values: "" )
      template.fields.create( position: 12, field_type: "number_field", field_label: "IMC", field_unit: "Kg/m2", field_values: "" )
      template.fields.create( position: 13, field_type: "number_field", field_label: "ACV", field_unit: "", field_values: "" )
      template.fields.create( position: 14, field_type: "text_field", field_label: "FC", field_unit: "", field_values: "" )
      template.fields.create( position: 15, field_type: "text_field", field_label: "PA", field_unit: "", field_values: "" )
      template.fields.create( position: 16, field_type: "text_field", field_label: "Aparelho respiratório", field_unit: "", field_values: "" )
      template.fields.create( position: 17, field_type: "text_field", field_label: "Sat", field_unit: "", field_values: "" )
      template.fields.create( position: 18, field_type: "text_field", field_label: "ABDM", field_unit: "", field_values: "" )
      template.fields.create( position: 19, field_type: "text_field", field_label: "MMIISS", field_unit: "", field_values: "" )
      template.fields.create( position: 20, field_type: "header", field_label: "Exames laboratoriais", field_unit: "", field_values: "" )
      template.fields.create( position: 21, field_type: "text_field", field_label: "ECG", field_unit: "", field_values: "" )
      template.fields.create( position: 22, field_type: "text_field", field_label: "FC", field_unit: "", field_values: "" )
      template.fields.create( position: 23, field_type: "text_field", field_label: "HT e HB", field_unit: "", field_values: "" )
      template.fields.create( position: 24, field_type: "text_field", field_label: "Coagulograma", field_unit: "", field_values: "" )
      template.fields.create( position: 25, field_type: "number_field", field_label: "Creatinina", field_unit: "mg/dl", field_values: "" )
      template.fields.create( position: 26, field_type: "text_field", field_label: "Outros", field_unit: "", field_values: "" )
      template.fields.create( position: 27, field_type: "text_field", field_label: "ECO", field_unit: "", field_values: "" )
      template.fields.create( position: 28, field_type: "text_field", field_label: "ECG", field_unit: "", field_values: "" )
      template.fields.create( position: 29, field_type: "text_area", field_label: "Risco", field_unit: "", field_values: "" )
      template.fields.create( position: 30, field_type: "text_area", field_label: "Recomendações", field_unit: "", field_values: "" )
      logger.info "Template created: Risco Cirúrgico"

    elsif type == 3 # FAO - Miria
      template = custom_form_templates.create( name: 'Acompanhamento de Casos Clínicos' )

      template.fields.create( position: 1, field_type: 'text_area', field_label: 'HPP', field_unit: '', field_values: "" )
      template.fields.create( position: 1, field_type: 'text_area', field_label: 'Observações / Testes Visuais', field_unit: '', field_values: "" )
      template.fields.create( position: 1, field_type: 'text_area', field_label: 'Observações', field_unit: '', field_values: "" )
      template.fields.create( position: 2, field_type: 'text_area', field_label: 'Queixa Pricipal', field_unit: '', field_values: "" )
      template.fields.create( position: 3, field_type: 'radio_group', field_label: 'Grau de Lesionalidade vs. Folhetos Embrionários', field_unit: '', field_values: "Ectoderma (ouvido, olhos, boca, pele)\r\nEndoderma (trato geniturinário, gastrointestinal ou respiratório)\r\nMesoderma (endócrino, órgãos e tecido conectivo)\r\nPlaca Neural (sistema nervoso)\u2028\r\nCélula (código genético)" )
      template.fields.create( position: 4, field_type: 'radio_group', field_label: 'Quadro', field_unit: '', field_values: "Agudo\r\nCrônico" )
      template.fields.create( position: 5, field_type: 'radio_group', field_label: 'Grau de Lesionalidade', field_unit: '', field_values: "Lesional Grave\r\nLesional Leve\r\nFuncional" )
      template.fields.create( position: 6, field_type: 'radio_group', field_label: 'Dominância Cerebral', field_unit: '', field_values: "Direita\r\nEsquerda" )
      template.fields.create( position: 7, field_type: 'radio_group', field_label: 'Esquema Terapêutico', field_unit: '', field_values: "Duplo\r\nTriplo\r\nPenta\r\nHepta\r\nOcta\r\nDodeca" )
      template.fields.create( position: 8, field_type: 'text_area', field_label: 'Potências', field_unit: '', field_values: "" )
      template.fields.create( position: 9, field_type: 'text_area', field_label: 'Data', field_unit: '', field_values: "" )
      template.fields.create( position: 10, field_type: 'radio_group', field_label: 'Outros Medicamentos', field_unit: '', field_values: "Sim\r\nNão" )
      template.fields.create( position: 11, field_type: 'text_area', field_label: 'Quais?', field_unit: '', field_values: "" )
      template.fields.create( position: 12, field_type: 'radio_group', field_label: 'Exames', field_unit: '', field_values: "Sim\r\nNão" )
      template.fields.create( position: 13, field_type: 'text_area', field_label: 'Quais?', field_unit: '', field_values: "" )
      template.fields.create( position: 14, field_type: 'header', field_label: 'Monitoramento 1', field_unit: '', field_values: "" )
      template.fields.create( position: 15, field_type: 'text_area', field_label: 'Tempo', field_unit: '', field_values: "" )
      template.fields.create( position: 16, field_type: 'text_area', field_label: 'Duração', field_unit: '', field_values: "" )
      template.fields.create( position: 17, field_type: 'header', field_label: 'Monitoramento 2', field_unit: '', field_values: "" )
      template.fields.create( position: 18, field_type: 'text_area', field_label: 'Tempo', field_unit: '', field_values: "" )
      template.fields.create( position: 19, field_type: 'text_area', field_label: 'Duração', field_unit: '', field_values: "" )
      template.fields.create( position: 20, field_type: 'text_area', field_label: 'Observações segundo as Leis de Cura', field_unit: '', field_values: "" )
      template.fields.create( position: 21, field_type: 'text_area', field_label: 'Observações segundo Padrões de Auto-Organização', field_unit: '', field_values: "" )
      template.fields.create( position: 22, field_type: 'text_area', field_label: 'Outras Observações', field_unit: '', field_values: "" )

#       # OLD

#       # custom_form_templates.create( name: "Acompanhamento de Casos Clínicos",
#       # notes: "Queixa Principal:\r\n\r\n( ) ECTODERMA (OUVIDO, OLHOS, BOCA, PELE)\r\n( ) ENDODERMA (TRATO GENITURINÁRIO, GASTROINTESTINAL OU RESPIRATÓRIO)\r\n( ) MESODERMA (ENDÓCRINO, ÓRGÃOS E TECIDO CONECTIVO)\u2028\r\n( ) PLACA NEURAL (SISTEMA NERVOSO)\u2028\r\n( ) CÉLULA (CÓDIGO GENÉTICO)\r\n\r\nQuadro:\r\n( ) Agudo\r\n( ) Crônico\r\n\r\nGrau de Lesionalidade:\r\n( ) Lesional Grave\r\n( ) Lesional Leve\r\n( ) Funcional\r\n\r\nEsquema Terapêutico:\r\n( ) Duplo\r\n( ) Triplo\r\n( ) Penta\r\n( ) Hepta\r\n\r\nPotências:\r\n\r\nData: \r\n\r\nOutros Medicamentos:\r\n( ) Sim\r\n( ) Não\r\n\r\nExames:\r\n( ) Sim\r\n( ) Não\r\n\r\nMonitoramento 1:\r\nTempo:\r\nDuração:\r\n\r\nMonitoramento 2:\r\nTempo:\r\nDuração:\r\n\r\nMonitoramento 3:\r\nTempo:\r\nDuração:\r\n\r\nObservações segundo as Leis de Cura:\r\n\r\nObservações segundo Padrões de Auto-Organização:\r\n\r\nOutras Observações:" )
#       template = custom_form_templates.create( name: 'Acompanhamento de Casos Clínicos' )
#       template.fields.create( position: 1, field_type: "radio_group", field_label: "Queixa Principal", field_unit: "",
#         field_values: "Ectoderma (ouvido, olhos, boca, pele)\r
# Endoderma (trato geniturinário, gastrointestinal ou respiratório)\r
# Mesoderma (endócrino, órgãos e tecido conectivo)\r
# Placa Neural (sistema nervoso) \r
# Célula (código genético)\r" )
#       template.fields.create( position: 2, field_type: "radio_group", field_label: "Quadro", field_unit: "",
#         field_values: "Agudo\r
# Crônico\r" )
#       template.fields.create( position: 3, field_type: "radio_group", field_label: "Grau de Lesionalidade", field_unit: "",
#         field_values: "Lesional Grave\r
# Lesional Leve\r
# Funcional\r" )
#       template.fields.create( position: 4, field_type: "radio_group", field_label: "Esquema Terapêutico", field_unit: "",
#         field_values: "Duplo\r
# Triplo\r
# Penta\r
# Hepta\r" )
#       template.fields.create( position: 5, field_type: "text_field", field_label: "Potências", field_unit: "", field_values: "" )
#       template.fields.create( position: 6, field_type: "text_field", field_label: "Data", field_unit: "", field_values: "" )
#       template.fields.create( position: 7, field_type: "radio_group", field_label: "Outros Medicamentos", field_unit: "",
#         field_values: "Sim\r
# Não\r" )
#       template.fields.create( position: 8, field_type: "radio_group", field_label: "Exames", field_unit: "",
#         field_values: "Sim\r
# Não\r" )
#       template.fields.create( position: 9, field_type: "header", field_label: "Monitoramento 1", field_unit: "", field_values: "" )
#       template.fields.create( position: 10, field_type: "text_field", field_label: "Tempo", field_unit: "", field_values: "" )
#       template.fields.create( position: 11, field_type: "text_field", field_label: "Duração", field_unit: "", field_values: "" )
#       template.fields.create( position: 12, field_type: "header", field_label: "Monitoramento 2", field_unit: "", field_values: "" )
#       template.fields.create( position: 13, field_type: "text_field", field_label: "Tempo", field_unit: "", field_values: "" )
#       template.fields.create( position: 14, field_type: "text_field", field_label: "Duração", field_unit: "", field_values: "" )
#       template.fields.create( position: 15, field_type: "text_area", field_label: "Observações segundo as Leis de Cura", field_unit: "", field_values: "" )
#       template.fields.create( position: 16, field_type: "text_area", field_label: "Observações segundo Padrões de Auto-Organização", field_unit: "", field_values: "" )
#       template.fields.create( position: 17, field_type: "text_area", field_label: "Outras Observações", field_unit: "", field_values: "" )
      logger.info "Template created: FAO - Miria"

    elsif type == 4 # Consulta primeira vez - Gustavo Gouvea
      custom_form_templates.create( name: "Consulta 1ª vez",
        notes: "Q.P.:\r\n\r\n\r\n\r\nH.D.A.:\r\n\r\n\r\n\r\nANTECEDENTES / FATORES DE RISCO:\r\nHipertensão: \r\n() Sim\r\n() Não\r\n\r\nDiabetes: \r\n() Sim\r\n() Não\r\n\r\nDislipidemia: \r\n() Sim\r\n() Não\r\n\r\n\r\nHISTÓRIA DA PESSOA:\r\nTabagismo: \r\n() Sim\r\n() Não\r\n\r\nEtilismo: \r\n() Sim\r\n() Não\r\n\r\nAtividade Física: \r\n() Sim\r\n() Não\r\n\r\n\r\nHISTÓRIA FAMILIAR:\r\nPai: \r\nMãe: \r\nIrmão: \r\nOutros: \r\n\r\nDAC Precoce: \r\n() Sim\r\n() Não\r\n\r\n\r\nREVISÃO DOS SISTEMAS\r\nAsma Brônquica / DPOC: \r\n() Sim\r\n() Não\r\n\r\nPneumopatias: \r\n() Sim\r\n() Não\r\n\r\nRinite: \r\n() Sim\r\n() Não\r\n\r\nSinusite: \r\n() Sim\r\n() Não\r\n\r\nAlergias Respiratórias: \r\n() Sim\r\n() Não\r\n\r\nAlergias Medicamentosas: \r\n() Sim\r\n() Não\r\n[] Penincilina\r\n[] Aspirina\r\n[] AINH\r\n[] Iodo\r\n[] Sulfa\r\n[] Dipirona\r\nOutras: \r\n\r\nDoenças Pépticas: \r\n() Sim\r\n() Não\r\n\r\nHepatopatias: \r\n() Sim\r\n() Não\r\n\r\nNefropatias: \r\n() Sim\r\n() Não\r\n\r\nTireoidopatias: \r\n() Sim\r\n() Não\r\n\r\nOutras doenças endócrinas: \r\n\r\nNeuropatias: \r\n() Sim\r\n() Não\r\n\r\nDoenças psiquiátricas: \r\n() Sim\r\n() Não\r\n\r\nAnemia / Doenças hematológicas: \r\n() Sim\r\n() Não\r\n\r\nNeoplasias: \r\n() Sim\r\n() Não\r\n[] Quimioterapia\r\n[] Radioterapia\r\n\r\nDoenças dermatológicas: \r\n() Sim\r\n() Não\r\n\r\nDoenças oculares: \r\n() Sim\r\n() Não\r\n[] Glaucoma\r\n[] Catarata\r\n\r\nTrumatismo: \r\n() Sim\r\n() Não\r\n\r\nCirurgias: \r\n() Sim\r\n() Não\r\n\r\nAdmissões Hospitalares: \r\n() Sim\r\n() Não\r\n\r\n\r\nMEDICAMENTOS:\r\nDe uso regular:\r\n\r\nDe uso esporádico:\r\n\r\nEfeitos colaterais:\r\n\r\n\r\nEXAME FÍSICO\r\nPeso:  kg\r\nAltura:  m\r\nIMC:  kg/m2\r\nCircunferência abdominal: \r\n\r\nPRESSÃO ARTERIAL\r\nDB deitado:  mmHg\r\nBE deitado:  mmHg\r\nDB sentado:  mmHg\r\nBE sentado:  mmHg\r\nFC:  bpm\r\n\r\nEstado Geral: \r\n\r\nCabeça / pescoço: \r\n\r\nRitmo cardíaco: \r\n() \r\n() Regular\r\n() \r\n\r\nSopro: \r\n() Sim\r\n() Não\r\n[] Sistólico: \r\n[] Diastólico: \r\n\r\nBulhas: \r\n[] B3\r\n[] B4\r\n\r\nTJP: \r\n() Sim\r\n() Não\r\n\r\nRHJ: \r\n() Sim\r\n() Não\r\n\r\nPulmões: \r\n\r\nAbdome: \r\n\r\n\r\nMEMBROS INFERIORES: \r\nEdema: \r\n() Sim\r\n() Não\r\n\r\nPulsos: \r\n() Isóbaros\r\n() \r\n\r\nNeuro: \r\n\r\nOutros: \r\n\r\nImpressão: \r\n\r\nConduta: " )
      logger.info "Template created: Consulta primeira vez - Gustavo Gouvea"
    elsif type == 5 # Consulta subsequente - Gustavo Gouvea
      custom_form_templates.create( name: "Consulta Subsequente",
        notes: "EXAME FÍSICO\r\nPeso:  kg\r\nAltura:  m\r\nIMC:  kg/m2\r\nCircunferência abdominal: \r\n\r\nPRESSÃO ARTERIAL\r\nDB deitado:  mmHg\r\nBE deitado:  mmHg\r\nDB sentado:  mmHg\r\nBE sentado:  mmHg\r\nFC:  bpm\r\n\r\nEstado Geral: \r\n\r\nCabeça / pescoço: \r\n\r\nRitmo cardíaco: \r\n() \r\n() Regular\r\n() \r\n\r\nSopro: \r\n() Sim\r\n() Não\r\n[] Sistólico: \r\n[] Diastólico: \r\n\r\nBulhas: \r\n[] B3\r\n[] B4\r\n\r\nTJP: \r\n() Sim\r\n() Não\r\n\r\nRHJ: \r\n() Sim\r\n() Não\r\n\r\nPulmões: \r\n\r\nAbdome: \r\n\r\n\r\nMEMBROS INFERIORES: \r\nEdema: \r\n() Sim\r\n() Não\r\n\r\nPulsos: \r\n() Isóbaros\r\n() \r\n\r\nNeuro: \r\n\r\nOutros: \r\n\r\nImpressão: \r\n\r\nConduta: " )
      logger.info "Template created: Consulta subsequente - Gustavo Gouvea"

    elsif type == 6 # Anamnese Lymark
      delete_anamnesis
      template = custom_form_templates.create( name: 'Anamnese', anamnesis: true )
      template.fields.create( position: 1, field_type: "radio_group", field_label: "Sofre de alguma doença?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 2, field_type: "text_field", field_label: "Qual(is)?", field_unit: "", field_values: "" )
      template.fields.create( position: 3, field_type: "radio_group", field_label: "Se mulher, está grávida?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 4, field_type: "number_field", field_label: "Há quanto tempo?", field_unit: "meses", field_values: "" )
      template.fields.create( position: 5, field_type: "radio_group", field_label: "Faz uso de anticoncepcional?", field_unit: "", field_values: "Sim\r\nNão\r" )

      template.fields.create( position: 6, field_type: "radio_group", field_label: "Está ou esteve recentemente em tratamento médico?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 7, field_type: "text_field", field_label: "Qual?", field_unit: "", field_values: "" )
      template.fields.create( position: 8, field_type: "text_field", field_label: "Nome do Médico Assistente", field_unit: "", field_values: "" )
      template.fields.create( position: 9, field_type: "text_field", field_label: "Telefone do Médico Assistente", field_unit: "", field_values: "" )

      template.fields.create( position: 10, field_type: "radio_group", field_label: "Está fazendo uso de alguma Medicação?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 11, field_type: "text_field", field_label: "Qual(is)?", field_unit: "", field_values: "" )

      template.fields.create( position: 12, field_type: "radio_group", field_label: "Tem algum tipo de alergia?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 13, field_type: "text_field", field_label: "Qual(is)?", field_unit: "", field_values: "" )

      template.fields.create( position: 14, field_type: "radio_group", field_label: "Já foi operado?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 15, field_type: "text_field", field_label: "Qual(is)?", field_unit: "", field_values: "" )
      template.fields.create( position: 16, field_type: "radio_group", field_label: "Teve problemas com a cicatrização?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 17, field_type: "radio_group", field_label: "Teve problemas com a anestesia?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 18, field_type: "radio_group", field_label: "Teve problemas de Hemorragia?", field_unit: "", field_values: "Sim\r\nNão\r" )

      template.fields.create( position: 19, field_type: "radio_group", field_label: "Faz uso de alguma substância tóxica?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 20, field_type: "text_field", field_label: "Qual(is)?", field_unit: "", field_values: "" )

      template.fields.create( position: 21, field_type: "radio_group", field_label: "É fumante?", field_unit: "", field_values: "Sim\r\nNão\r" )
      template.fields.create( position: 22, field_type: "number_field", field_label: "Há quanto tempo?", field_unit: "meses", field_values: "" )

      template.fields.create( position: 23, field_type: "radio_group", field_label: "Tem histórico familiar de doenças cardíacas?", field_unit: "", field_values: "Sim\r\nNão\r" )

      template.fields.create( position: 24, field_type: "check_box", field_label: "Sofre de alguma das seguintes doenças?", field_unit: "",
        field_values: "Febre Reumática\r
Problemas Articulares ou Reumatismo\r
Problemas Cardíacos\r
Hipertensão Arterial\r
Problemas Renais\r
Anemia\r
Problemas Gástricos\r
Hepatite\r
Problemas Respiratórios\r
Sífilis\r
Problemas Alérgicos\r
HIV\r
Tuberculose\r
Hormônios\r
Asma\r
Alcoolista\r
Tatuagens\r
Herpes/Aftas\r
Desmaios\r
Diabetes\r
Epilepsia\r
Tumor\r
Problemas de Cicatrização\r
Distúrbios Psicológicos\r
Endocardite Bacteriana\r
AVC\r" )

      template.fields.create( position: 25, field_type: "text_field", field_label: "Há alguma outra informação importante sobre sua saúde que não tenhamos perguntado aqui?", field_unit: "", field_values: "" )
      template.fields.create( position: 26, field_type: "number_field", field_label: "Peso atual", field_unit: "Kg", field_values: "" )
      template.fields.create( position: 27, field_type: "number_field", field_label: "Altura", field_unit: "m", field_values: "" )

      template.fields.create( position: 28, field_type: "text_field", field_label: "Queixa principal que o motivou ao procurar atendimento", field_unit: "", field_values: "" )
      logger.info "Template created: Anamnesis Lymark"

    elsif type == 7 # Anamnese Andrea Tedesco - dentista estético
      delete_anamnesis
      template = custom_form_templates.create( name: 'Anamnese', anamnesis: true )

      template.fields.create( field_label: "Está em tratamento médico atualmente?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 1  )
      template.fields.create( field_label: "Nome e telefone do médico responsável", field_type: "text_field", field_unit: "", field_values: "", position: 2 )
      template.fields.create( field_label: "Se mulher, está grávida?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 3 )
      template.fields.create( field_label: "Faz uso de alguma medicação?", field_type: "radio_group", field_unit: "meses", field_values: "Sim\r\nNão", position: 4 )
      template.fields.create( field_label: "Qual(is)?", field_type: "text_field", field_unit: "", field_values: "Sim\r\nNão", position: 5 )
      template.fields.create( field_label: "Tem alergia a algum medicamento?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 6 )
      template.fields.create( field_label: "Qual(is)?", field_type: "text_field", field_unit: "", field_values: "", position: 7 )
      template.fields.create( field_label: "Sofre de alguma das seguintes doenças?", field_type: "check_box", field_unit: "", field_values: "Asma / Rinite alérgica\r\nSinusite\t\t\r\nAlergia\t\t\r\nTuberculose\t\r\nHipertensão\t\r\nProblemas cardiovasculares\r\nEndocardite bacteriana\r\nAVC\r\nDiabetes\r\nHipo/Hipertireoidismo\r\nEpilepsia\r\nProblemas renais\t\r\nHepatite\r\nDoenças sanguíneas\r\nTraumatismo crânio-facial\r\nOsteoporose\t\r\nCâncer\t\t\r\nAIDS\t\t\r\nSífilis\t\t\r\nHerpes labial\r\nTabagismo\t\r\nAlcoolismo\t\r\nUso de drogas ilícitas\r\nProblemas com anestesia\r\nProblemas de cicatrização\r\nHemorragia", position: 8 )
      template.fields.create( field_label: "Outras", field_type: "text_field", field_unit: "", field_values: "", position: 9 )
      template.fields.create( field_label: "Observações do Dentista", field_type: "text_area", field_unit: "", field_values: "", position: 10 )
      template.fields.create( field_label: "Análise Oral e Estética", field_type: "header", field_unit: "", field_values: "Sim\r\nNão", position: 11 )
      template.fields.create( field_label: "Queixa principal", field_type: "text_area", field_unit: "", field_values: "", position: 12 )
      template.fields.create( field_label: "Com qual frequência você visita seu dentista?", field_type: "text_field", field_unit: "", field_values: "Sim\r\nNão", position: 13 )
      template.fields.create( field_label: "Quantas vezes por dia escova seus dentes", field_type: "text_field", field_unit: "", field_values: "", position: 14 )
      template.fields.create( field_label: "Usa fio dental?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 15 )
      template.fields.create( field_label: "Tem hábito de roer unha?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 16 )
      template.fields.create( field_label: "Sua gengiva costuma sangrar durante a escovação?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 17 )
      template.fields.create( field_label: "Você acha que tem mau hálito?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 18 )
      template.fields.create( field_label: "Sente sensibilidade nos dentes?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 19 )
      template.fields.create( field_label: "Já notou alguma mobilidade em seus dentes?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 20 )
      template.fields.create( field_label: "Tem hábito de morder caneta, lápis, gelo?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 21 )
      template.fields.create( field_label: "Tem dificuldade de abrir a boca?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 22 )
      template.fields.create( field_label: "Tem hábito de ranger os dentes durante o dia ou a noite?", field_type: "radio_group", field_unit: "meses", field_values: "Sim\r\nNão", position: 23 )
      template.fields.create( field_label: "Acorda com a musculatura da face cansada?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 24 )
      template.fields.create( field_label: "Respira pela boca quando dorme?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 25 )
      template.fields.create( field_label: "Tem dificuldade de mastigar normalmente?", field_type: "radio_group", field_unit: "Kg", field_values: "Sim\r\nNão", position: 26 )
      template.fields.create( field_label: "Tem dificuldade fonética?", field_type: "radio_group", field_unit: "m", field_values: "Sim\r\nNão", position: 27 )
      template.fields.create( field_label: "Você se sente confortável ao sorrir presença de outras pessoas?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 28 )
      template.fields.create( field_label: "Você gostaria de ter dentes mais claros?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 29 )
      template.fields.create( field_label: "Você gosta da forma dos seus dentes?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 30 )
      template.fields.create( field_label: "Você gosta do tamanho dos seus dentes?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 31 )
      template.fields.create( field_label: "Existem espaços entre seus dentes que não lhe agradam?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 32 )
      template.fields.create( field_label: "Você acha que sua gengiva aparece demais ao sorrir?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 33 )
      template.fields.create( field_label: "Há restaurações escuras nos seus dentes que você gostaria de trocar por outras mais estéticas?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 34 )
      template.fields.create( field_label: "Nas fotografias, você geralmente possui alguma queixa sobre seu sorriso?", field_type: "radio_group", field_unit: "", field_values: "Sim\r\nNão", position: 35 )
      template.fields.create( field_label: "Resumidamente, o que você gostaria de mudar no seu sorriso?", field_type: "text_area", field_unit: "", field_values: "", position: 36 )
      template.fields.create( field_label: "Observações do Dentista", field_type: "text_area", field_unit: "", field_values: "", position: 37 )
      logger.info "Template created: Anamnesis Andrea Tedesco"

    elsif type == 8 # Anamnses Fabricio - medicos do fundão
      delete_anamnesis
      template = custom_form_templates.create( name: 'Anamnese', anamnesis: true )
      template.fields.create( position: 1, field_type: 'text_area', field_label: 'Q.P.', field_unit: '', field_values: "" )
      template.fields.create( position: 2, field_type: 'text_area', field_label: 'H.D.A.', field_unit: '', field_values: "" )
      template.fields.create( position: 3, field_type: 'header', field_label: 'Anamnese Dirigida', field_unit: '', field_values: "" )
      template.fields.create( position: 4, field_type: 'check_box', field_label: 'Geral', field_unit: '', field_values: "Emagrecimento\r\nFadiga\r\nInsônia\r\nVisão\r\nAudição\r\nZumbido\r\nCefaléia\r\nVertigens\r\nTonteiras" )
      template.fields.create( position: 5, field_type: 'check_box', field_label: 'Pele, Fâneros e Mucosas', field_unit: '', field_values: "Alterações da cor\r\nPrurido\r\nLesões" )
      template.fields.create( position: 6, field_type: 'check_box', field_label: 'Nariz e Seios Paranasais', field_unit: '', field_values: "Dor\r\nEpistaxes\r\nObstrução" )
      template.fields.create( position: 7, field_type: 'check_box', field_label: 'Boca e Garganta', field_unit: '', field_values: "Dentes\r\nGengivas\r\nRouquidão" )
      template.fields.create( position: 8, field_type: 'check_box', field_label: 'Pescoço', field_unit: '', field_values: "Dor\r\nTumorações" )
      template.fields.create( position: 9, field_type: 'check_box', field_label: 'Mamas', field_unit: '', field_values: "Nódulos\r\nDor\r\nSecreção" )
      template.fields.create( position: 10, field_type: 'text_area', field_label: 'Ap. Cardíaco: Dor ou desconforto: Qualidade, Severidade, Localização, Irradiação, Duração, Periodicidade, Modo de Início, Fatores Precipitantes e Agravantes, Alívio da Dor e Sinais Acompanhantes', field_unit: '', field_values: "" )
      template.fields.create( position: 11, field_type: 'check_box', field_label: 'Ap. Cardíaco: Dispinéia aos Esforços:', field_unit: '', field_values: "Grandes\r\nMédios\r\nPequenos\r\nRepouso\r\nOrtopnéia\r\nDispnéia\r\nParoxistica noturna\r\nSuspirosa\r\nPalpitações\r\nTosse\r\nCianose-Hemoptise\r\nSíncope\r\nEdema" )
      template.fields.create( position: 12, field_type: 'check_box', field_label: 'Aparelho Respiratório', field_unit: '', field_values: "Chiado\r\nInfecção Respiratória\r\nTosse\r\nExpectoração" )
      template.fields.create( position: 13, field_type: 'check_box', field_label: 'Ap. Digestivo', field_unit: '', field_values: "Disfagia\r\nPirose\r\nEpigastralgia\r\nDor Abdominal\r\nFuncionamento Intestinal\r\nHemorróidas\r\nSangramento Digestivo\r\nUso de Medicação" )
      template.fields.create( position: 14, field_type: 'check_box', field_label: 'Ap. Gênito-Urinário', field_unit: '', field_values: "Alterações da Cor da Urina\r\nVolume\r\nFrequência\r\nDisúria\r\nNictúria\r\nSecreção\r\nImpotência\r\nAlterações Menstruais\r\nSangramento Anormal" )
      template.fields.create( position: 15, field_type: 'check_box', field_label: 'Sist. Nervoso', field_unit: '', field_values: "Paresias\r\nParestesias\r\nTremores\r\nAusências\r\nConvulsões" )
      template.fields.create( position: 16, field_type: 'check_box', field_label: 'Ap. Locomotor', field_unit: '', field_values: "Dor\r\nImpotência Funcional" )
      template.fields.create( position: 17, field_type: 'check_box', field_label: 'Psiquismo', field_unit: '', field_values: "Ansiedade\r\nDepressão\r\nAlucinações" )
      template.fields.create( position: 19, field_type: 'header', field_label: 'História Patológica Pregressa', field_unit: '', field_values: "" )
      template.fields.create( position: 20, field_type: 'check_box', field_label: 'Doenças Infecciosas e Parasitárias', field_unit: '', field_values: "Doenças comuns da infância\r\nDoenças venéreas\r\nFebre de causa indeterminada\r\nAmigdalite\r\nFebre Reumática\r\nHepatite\r\nInfecção Urinária\r\nTurberculose\r\nPneumunia" )
      template.fields.create( position: 21, field_type: 'check_box', field_label: 'Manif. Alérgicas', field_unit: '', field_values: "Asma\r\nRinite\r\nUrticária\r\nEczema\r\nAlergia medicamentosa e alimentar" )
      template.fields.create( position: 22, field_type: 'text_area', field_label: 'Cirurgias / Traumas / Transfusões', field_unit: '', field_values: "" )
      template.fields.create( position: 23, field_type: 'text_area', field_label: 'Uso prolongado de medicamentos', field_unit: '', field_values: "" )
      template.fields.create( position: 25, field_type: 'header', field_label: 'Outras Doenças', field_unit: '', field_values: "" )
      template.fields.create( position: 26, field_type: 'check_box', field_label: 'Outras doenças', field_unit: '', field_values: "Diabetes\r\nHipertensão\r\nCardiopatias\r\nAlt. Lipidios\r\nNefropatias\r\nÚlcera péptica\r\nNeoplastia\r\nEpilepsia\r\nNeurose\r\nGlaucoma\r\nGota" )
      template.fields.create( position: 27, field_type: 'text_area', field_label: 'Obs', field_unit: '', field_values: "" )
      template.fields.create( position: 28, field_type: 'header', field_label: 'História Fisiológica', field_unit: '', field_values: "" )
      template.fields.create( position: 29, field_type: 'text_area', field_label: 'Nascimento - Crescimento - Puberdade - Menarca - Catamênios - Gestação - Climatério', field_unit: '', field_values: "" )
      template.fields.create( position: 30, field_type: 'header', field_label: 'História da Pessoa', field_unit: '', field_values: "" )
      template.fields.create( position: 31, field_type: 'text_area', field_label: 'Alimentação - Moradia - Hábitos (fumo - álcool - anticoncepcionais - tóxicos - exercícios) - circunstância da vida ao se iniciar a doença - desejo de outros filhos', field_unit: '', field_values: "" )
      template.fields.create( position: 32, field_type: 'header', field_label: 'Exame Físico', field_unit: '', field_values: "" )
      template.fields.create( position: 33, field_type: 'number_field', field_label: 'Peso', field_unit: 'Kg', field_values: "" )
      template.fields.create( position: 34, field_type: 'number_field', field_label: 'Altura', field_unit: 'cm', field_values: "" )
      template.fields.create( position: 35, field_type: 'number_field', field_label: 'IMC', field_unit: 'Kg / cm', field_values: "" )
      template.fields.create( position: 36, field_type: 'number_field', field_label: 'Tax', field_unit: '', field_values: "" )
      template.fields.create( position: 37, field_type: 'number_field', field_label: 'Respiração', field_unit: '', field_values: "" )
      template.fields.create( position: 38, field_type: 'number_field', field_label: 'Pulso', field_unit: '', field_values: "" )
      template.fields.create( position: 39, field_type: 'number_field', field_label: 'PA - BD - Deitado', field_unit: '', field_values: "" )
      template.fields.create( position: 40, field_type: 'number_field', field_label: 'PA - BD - Sentado', field_unit: '', field_values: "" )
      template.fields.create( position: 41, field_type: 'number_field', field_label: 'PA - BD - Em Pé', field_unit: '', field_values: "" )
      template.fields.create( position: 42, field_type: 'number_field', field_label: 'PA - BE - Deitado', field_unit: '', field_values: "" )
      template.fields.create( position: 43, field_type: 'number_field', field_label: 'PA - BE - Sentado', field_unit: '', field_values: "" )
      template.fields.create( position: 44, field_type: 'number_field', field_label: 'PA - BE - Em Pé', field_unit: '', field_values: "" )
      template.fields.create( position: 45, field_type: 'text_area', field_label: 'Exame Geral: Inspeção geral: Pele - Nutrição - Fâneros - Estado mental', field_unit: '', field_values: "" )
      template.fields.create( position: 46, field_type: 'text_area', field_label: 'Cabeça: Tireóide - Linfonodos - Vasos', field_unit: '', field_values: "" )
      template.fields.create( position: 47, field_type: 'text_area', field_label: 'Tórax: Inspeção geral - Fossa supraclavicular linfonodos', field_unit: '', field_values: "" )
      template.fields.create( position: 48, field_type: 'text_area', field_label: 'Ap. Respiratório: Dispnéia - Frêmitos - Percussão - Auscuta', field_unit: '', field_values: "" )
      template.fields.create( position: 49, field_type: 'text_area', field_label: 'Ap. Cardíaco: Abaulamento e retrações - Ritmo Ictus - Ritmo e frequência cardíaca (Frêmitos - Bulhas - Ruidos Anormais - Sopros)', field_unit: '', field_values: "" )
      template.fields.create( position: 50, field_type: 'text_area', field_label: 'Abdômen e Região Lombar: Inspeção geral - Sopros - Volume e forma - Macicês - Percussão - Timpanismo - Circ. colateral - Hérnias - Movimentos - Rigidez - Tensão - Ruidos hidroaéreos - Dor', field_unit: '', field_values: "" )
      template.fields.create( position: 51, field_type: 'text_area', field_label: 'Fígado: Hepatimetria - Consistência - Borda - Sensibilidade - Superfície - Ponto cístico - Manobra de Murphy', field_unit: '', field_values: "" )
      template.fields.create( position: 52, field_type: 'text_area', field_label: 'Baço: Espaço de Traube - Consistência - Toque Retal', field_unit: '', field_values: "" )
      template.fields.create( position: 53, field_type: 'text_area', field_label: 'Gênito Urinária: Punho percussão lombar - Globo Vesical - Pontos Renoureterais', field_unit: '', field_values: "" )
      template.fields.create( position: 54, field_type: 'text_area', field_label: 'Membros: Inspeção geral - Varizes - Edema - Enchimento Capilar - P.A. no membro inferior - Pulsos: Carotideo - Radial - Umeral - Femural - Popliteo - Pedioso - Tibial posterior', field_unit: '', field_values: "" )
      template.fields.create( position: 55, field_type: 'text_area', field_label: 'Sistema Nervoso e Ósteo Articular: Estática - Reflexos - Marcha - Sensibilidade - Força Muscular - Alterações Articulares', field_unit: '', field_values: "" )
    end
  end

  def default_prescription_template(cat, type)
    if cat == 'prescricoes'
      category = "Prescrição"

    elsif cat == 'exames'
      category = "Exame"

    elsif cat == 'atestados'
      category = "Atestado"
      if type == 1
        title = "Atestado Trabalhista"
        content = "<p>Atesto para fins trabalhistas que o(a) paciente esteve sob meus cuidados profissionais, na data de hoje, devendo permanecer em repouso por 48 horas.</p>"
      elsif type == 2
        title = "Atestado Escolar"
        content = "<p>Atesto para devidos fins escolares, que o(a) paciente, esteve sob os meus cuidados profissionais para um atendimento, não podendo assim comparecer as suas atividades normais por 48 horas.</p>"
      elsif type == 3
        title = "ASO - Atestado de Saúde Ocupacional"
        content = "<p>.</p>"
      end
    end

    if category && title && content
      prescription_templates.create( name: title, content: content, category: category )
    else
      p "CODE ERROR"
    end
  end

  def free_consultation
    custom_procedures.find_by_free(true)
  rescue
    nil
  end

  private
  def delete_anamnesis
    custom_form_templates.where(anamnesis: true).each do |anamnesis|
      anamnesis.update_attributes(deleted_at: DateTime.now)
    end
  end

  def auto_setup_models
    custom_procedures.create( name: "Consulta" )
    custom_procedures.create( name: "Consulta Grátis", price: 0, free: true )
    default_custom_form_template(6)
    tag_templates.create( name: 'VIP', vip: true )
    tag_templates.create( name: 'Em Tratamento' )
    tag_templates.create( name: 'Inativo' )
    default_prescription_template('atestados',1)
    default_prescription_template('atestados',2)
  end

  def build_default_profile
    # build default profile instance. Will use default params.
    # The foreign key to the owning User model is set automatically
    build_profile
    true # Always return true in callbacks as the normal 'continue' state
         # Assumes that the default_profile can **always** be created.
         # or
         # Check the validation of the profile. If it is not valid, then
         # return false from the callback. Best to use a before_validation
         # if doing this. View code should check the errors of the child.
         # Or add the child's errors to the User model's error array of the :base
         # error item end
  end
end
