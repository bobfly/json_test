class Demo < ActiveRecord::Base
  def self.create_patient(user, clinic)
    profession = user.profession
    doctor = user.doctor

    # patient = doctor.patients.new(
    patient = doctor.patients.create(
      clinic_id: clinic.id,
      name: "Paciente Exemplo",
      completed: true,
      demo: true,
      birthdate: 72.years.ago,
      mobile_phone: "(21) 98893-0340",
      email: "paciente@exemplo.com",
      address_street: "Rua do Catete",
      address_number: "153",
      address_extra: "",
      address_neighborhood: 'Catete',
      address_city: 'Rio de Janeiro',
      address_state: 'RJ',
      address_zipcode: "22220-000",
      notes: "Esse é um paciente ficticio, qualquer semelhança é mera coincidência ;)",
      gender: 'male' )

    # p patient
    # if profession == 'Dentista'
    #   self.demo_dentist_timeline(patient, clinic, doctor)
    # else
    #   self.demo_orthopedist_timeline(patient, clinic, doctor)
    # end
    self.demo_orthopedist_timeline(patient, clinic, doctor)
    self.add_patient_picture(patient)
  end

  private

  def self.create_attachments_for(record, file_name)
    file = File.open(Rails.root.join("db/fixtures/#{file_name}")) rescue nil
    if file
      record.attachments.create(file: file, test_record: true)
    else
      puts "ERROR - file not found : #{file_name}"
    end
  end

  def self.add_patient_picture(patient)
    file_name = 'patient_demo_pic.jpg'
    file = File.open(Rails.root.join("db/fixtures/#{file_name}")) rescue nil
    if file
      PatientProfileImage.create(file: file, test_record: true, patient_id: patient.id)
    else
      puts "ERROR - file not found : #{file_name}"
    end
  end

  def self.demo_dentist_timeline(patient, clinic, doctor)
    user = doctor.user
    today = Date.today

    ### Case - GNT - Super Bonita ###

    # <1ª consulta>
    date = today -30 -5 -10 -3 -2 -5 -2 -7
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 60 , title: '', note: '' , column: 1, confirmed_at: date - 1, confirmed_by_user_id: user )
    appointment.record.update_attributes(
      finished_at: date,
      title: "1a consulta",
      description: "Exame Clínico + Anamnese + Odontograma

    Fotos iniciais para planejamento de DSD e lentes de contato
    Paciente com diastemas na Bateria Labial Superior e restaurações deficientes de forma e tamanho.
    21: classe IV insatisfatória
    Paciente deseja aumentar tamanho dos dentes
    Moldagem superior e inferior com alginato para confecção das moldeiras de clareamento

    Próxima consulta: análise de DSD + clareamento")

    # Pedido de Exame
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 10, min: 25)
    prescription = appointment.prescriptions.create( doctor_id: doctor.id, category: 'Exame',
      content: "<p><span>SOLICITAÇÃO DE EXAME RADIOGRÁFICO<br></span></p><p>Venho por meio desta, solicitar exame periapical completo com radiografias interproximais e panorâmica.</p>" )
    prescription.update_attributes( created_at: datetime )
    prescription.appointment.record.update_attributes( date: datetime )
    # >>> anexos


    # <2ª consulta - D+7 dias>
    date = today -30 -5 -10 -3 -2 -5 -2
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1, confirmed_at: date - 1, confirmed_by_user_id: user )
    appointment.record.update_attributes(
      finished_at: date,
      title: "Análise do DSD",
      description: "Discussão e aprovação do planejamento Digital do Sorriso junto com o paciente.
    Clareamento de consultório com Whiteness HP Blue 37% por 40 minutos
    Entrega das placas de clareamento + 1 seringa de Whiteness 10% para uso noturno + 1 seringa de Whiteclass 7.5% para uso diurno por 30 minutos")
    # >>> anexos

    # Prescrição
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 10, min: 25)
    prescription = appointment.prescriptions.create( doctor_id: doctor.id, category: 'Prescrição',
      content: "<p>Clareamento Caseiro Supervisionado</p><p>1. Escovar os dentes<br>2. Dispensar 1 gota de gel por dente no interior da moldeira<br>3. Colocar a moldeira na boca e apertar o gel de encontro aos dentes<br>4. Remover possíveis excessos de gel<br>5. Permanecer pelo tempo determinado<br>6. Retirar a moldeira da boca<br>7. Remover o excesso de gel sobre os dentes com uma gaze e bochechos<br>8. Escovar a moldeira<br>9. Aguardar 20 minutos e escovar os dentes</p><p>Uso noturno (noite inteira ou mínimo de 4 horas)<b><br></b>Gel:</p><p>Uso diurno<b><br></b>Gel:</p><p>Ocasionalmente pode ocorrer sensibilidade ao frio / vento ou ulceração gengival em intensidade leve a moderada. Nestes casos, comunicar seu dentista imediatamente para que o tratamento seja reconduzido.<br>Consultas semanais devem ser marcadas para controle da alteração cromática e inspeção dos tecidos gengivais.</p>" )
    prescription.update_attributes( created_at: datetime )
    prescription.appointment.record.update_attributes( date: datetime )


    # <3ª consulta - D+7+2 dias>
    date = today -30 -5 -10 -3 -2 -5
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1, confirmed_at: date - 1, confirmed_by_user_id: user )
    appointment.record.update_attributes(
      finished_at: date,
      title: "Remoção das restaurações antigas",
      description: "21/11/12/13/22 - Remoção das resinas proximais + moldagem de alginato para laboratório MW avaliar necessidade de desgastes para lentes de contato de 13 a 23.")
    # >>> anexos


    # <Evento - D+7+2 dias>
    date = today -30 -5 -10 -3 -2 -5
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 12)
    patient.records.create( date: datetime, user_id: user.id,
      title: "Saída de trabalho para laboratório MW",
      description: "Expectativa de chegada em até 5 dias" )


    # <4ª consulta - D+7+2+5 dias>
    date = today -30 -5 -10 -3 -2
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1,
      canceled_by_doctor_at: (date - 1) )
    appointment.record.update_attributes(
      finished_at: date,
      title: "Atraso na entrega do trabalho pelo laboratório",
      description: "")


    # <Evento - D+7+2+5+2 dias>
    date = today -30 -5 -10 -3
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 12)
    patient.records.create( date: datetime, user_id: user.id,
      title: "Chegada do trabalho do laboratório",
      description: "" )


    # <5ª consulta - D+7+2+5+2+3 dias>
    date = today -30 -5 -10
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 60 , title: '', note: '' , column: 1, confirmed_at: date - 1, confirmed_by_user_id: user )
    appointment.record.update_attributes(
      finished_at: date,
      title: "21/11/12/13/22 - Ajustes solicitados pelo laboratório MW + moldagem de trabalho",
      description: "Ajustes solicitados pelo laboratório:
    21- Igualar com o 11
    11- Remover retenção cervical e deixar distal expulsiva como o 21
    12- Suave desgaste para deixar mais expulsivo
    13- Jogar a distal para palatina
    22- Desgastar o máximo possível a distal para redistribuir a proporção e aumentar a ameia incisal entre 22 e 23
    22 e 21 são os mais problemáticos, não ficar com pena, pois o sucesso do trabalho pode estar ai

    Procedimentos efetuados:
    21- Index com virtual pesado para colagem do fragmento.
    Restauração provisória englobando o fragmento com protemp cor A2 no index.
    Cimentação com resina Variolink A1 + foto + polimento
    23- Gengiva precisa ser condicionada.
    Ajustes solicitados pelo laboratório realizados
    BLS- Moldagem de trabalho com fio retrator 000 e 00 + virtual pesado e leve + registro com Oclufast + antagonista com alginato")
    # >>> 21 anexos

    # <Evento - D+7+2+5+2+3 dias>
    date = today -30 -5 -10
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 12)
    patient.records.create( date: datetime, user_id: user.id,
      title: "Saída de trabalho para laboratório MW",
      description: "Expectativa de chegada em até 10 dias" )


    # <Evento - D+7+2+5+2+3+10 dias>
    date = today -30 -5
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 12)
    patient.records.create( date: datetime, user_id: user.id,
      title: "Chegada do trabalho do laboratório",
      description: "" )


    # <6ª consulta - D+7+2+5+2+3+10+5 dias>
    date = today -30
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1, confirmed_at: date - 1, confirmed_by_user_id: user )
    appointment.record.update_attributes(
      finished_at: date,
      title: "Prova das lentes de contato",
      description: "Prova das lentes de contato com Variolink Veneer Try in. Cor selecionada +1 para os incisivos e 0 para os caninos. Sem necessidade de ajuste. Excelente adaptação e cor.")


    # <7ª consulta - D+7+2+5+2+3+10+5+30 dias>
    date = today
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 11 - 3, min: 30), duration: 60 , title: '', note: '' , column: 1, confirmed_at: date - 1, confirmed_by_user_id: user )
    appointment.record.update_attributes(
      finished_at: date,
      title: "Cimentação das lentes de contato",
      description: "Isolamento modificado de 15 a 25 + fio retrator 000 + cimentação com SBMU + Variolink Veneer cor +1 para os incisivos e 0 para os caninos. Ajuste oclusal + acabamento e polimento.")
  end

  def self.demo_orthopedist_timeline(patient, clinic, doctor)
    user = doctor.user
    today = Date.today

    date = today -7 -10 -7 -10
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1 )
    appointment.record.update_attributes(
      description: "Paciente com relato de entorse de joelho D durante partida de futebol

    Apresenta dificuldade deambulação, dor e edema locais.

    Exame físico:
    Sinal da gaveta positivo, bloqueio articular.
    Lesão de LCA?
    Hemartrose?
    Lesão meniscal?

    Conduta:
    AINE + Analgésico
    repouso
    gelo local
    solicito RNM")

    # <receita>
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 10, min: 20)
    prescription = appointment.prescriptions.create( doctor_id: doctor.id, category: 'Prescrição',
      content: "<u><b>Uso interno:</u></b>

    <b>1. Nimesulida 100mg</b>
    Tomar 1cp 12/12 hs por 5 dias

    <b>2. Dipirona 500mg</b>
    Tomar 2cp 4/4 hs em caso de dor


    <u><b>Orientação:</u></b>

    1. Aplicar gelo local 3 a 4 x/dia

    2. Manter o membro elevado" )
    prescription.update_attributes( created_at: datetime )
    prescription.appointment.record.update_attributes( date: datetime )


    # <Pedido de Exame>
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 10, min: 25)
    prescription = appointment.prescriptions.create( doctor_id: doctor.id, category: 'Exame',
      content: "<u><b>Solicito:</u></b>

    RNM de joelho D" )
    prescription.update_attributes( created_at: datetime )
    prescription.appointment.record.update_attributes( date: datetime )

    # <2ª consulta - D+10 dias>
    date = today -7 -10 -7
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1 )
    appointment.record.update_attributes(
      description: "Paciente relata melhora significativa da dor e do edema.
    Mantém sinal da gaveta.
    RNM revela lesão completa de LCA, lesão de menisco lateral e hematose discreta.

    Conduta:
    Solicito exames pré-operatórios.")
    # — anexo — rnm.jpg —
    self.create_attachments_for(appointment.record, 'RNM.jpg')

    # <Pedido de Exame>
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 10, min: 15)
    prescription = appointment.prescriptions.create( doctor_id: doctor.id, category: 'Exame',
      content: "<u><b>Solicito:</u></b>

    Hemograma completo

    Coagulograma" )
    prescription.update_attributes( created_at: datetime )
    prescription.appointment.record.update_attributes( date: datetime )

    # <3ª consulta - D+10+7dias>
    date = today -7 -10
    surgery_date = date + 10
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 10), duration: 30 , title: '', note: '' , column: 1 )
    appointment.record.update_attributes(
      description: "Exames laboratoriais sem alterações
    Liberado para cirurgia
    Cirurgia proposta p/ #{I18n.l surgery_date, format: :long}, aguardando liberação do convênio.")
    # — anexo — exames
    self.create_attachments_for(appointment.record, 'Hemograma.pdf')


    # <Evento - D+10+7+5dias>
    date = today -7 -5
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 12)
    patient.records.create( date: datetime, user_id: user.id,
      title: "Procedimento autorizado pelo convênio.",
      description: "Cirurgia marcada na casa de saúde Santa Maria no dia #{surgery_date.strftime('%d/%m')}" )

    # <Evento - D+10+7+10dias>
    date = surgery_date # today -7
    datetime = DateTime.now.change( day: date.day, month: date.month, year: date.year, hour: 12)
    patient.records.create( date: datetime, user_id: user.id,
      title: 'Cirurgia sem intercorrência' )

    # <4ª consulta - D+10+7+10+7dias>
    date = today
    appointment = patient.appointments.create( date: date, clinic_id: clinic.id, doctor_id: doctor.id,
      time: Time.new.change(hour: 8, min: 30), duration: 60 , title: '', note: '' , column: 1 )
    appointment.record.update_attributes(
      description: "Paciente em bom estado geral, queixando-se de dor compatível com o pós-operatório.
    Ferida operatória limpa, sem sinais de infeção.

    Conduta:
    Oriento início de fisioterapia
    Retorno em 1 semana")
  end
end
