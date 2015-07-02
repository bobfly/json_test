# encoding:utf-8

class Profession
  NAMES = {
    "Dentista" => {
      name: "dentista",
      name_plural: "dentistas",
      council: "CRO",
      specialty: {
        101 => "Cirurgião Dentista",
        102 => "Cirurgião Bucomaxilofacial",
        103 => "Dentista Clínico Geral",
        104 => "Dentística (Estética)",
        105 => "Endodontista",
        106 => "Implantodontista",
        107 => "Odontopediatra",
        108 => "Ortodontista",
        109 => "Periodontista",
        110 => "Protesista"
      }
    },

    "Médico" => {
      name: "médico",
      name_plural: "médicos",
      council: "CRM",
      specialty: {
        201 => "Médico",
        202 => "Alergista e Imunologista",
        203 => "Anestesiologista",
        204 => "Angiologista",
        205 => "Cardiologista",
        206 => "Cirurgião Cardiovascular",
        207 => "Cirurgião de Cabeça e Pescoço",
        208 => "Cirurgião do Aparelho Digestivo",
        209 => "Cirurgião Geral",
        210 => "Cirurgião Pediátrico",
        211 => "Cirurgião Plástico",
        212 => "Cirurgião Torácico",
        213 => "Clinico Geral",
        214 => "Coloproctologista",
        215 => "Dermatologista",
        216 => "Endocrinologista",
        217 => "Fisiatra",
        218 => "Gastroenterologista",
        219 => "Geneticista",
        220 => "Geriatra",
        221 => "Ginecologista e Obstetra",
        222 => "Hematologista",
        223 => "Homeopata",
        224 => "Infectologista",
        225 => "Mastologista",
        226 => "Médico do Trabalho",
        227 => "Nefrologista",
        228 => "Neurocirurgião",
        229 => "Neurologista",
        230 => "Nutrólogo",
        231 => "Oftalmologista",
        232 => "Oncologista",
        233 => "Ortopedista e Traumatologista",
        234 => "Otorrinolaringologista",
        235 => "Pediatra",
        236 => "Pneumologista",
        237 => "Psiquiatra",
        238 => "Reumatologista",
        239 => "Urologista"
      }
    },

    "Outros" => {
      name: "profissional",
      name_plural: "profissionais",
      council: "",
      specialty: {
        301 => "Outra Profissão",
        302 => "Acupunturista",
        303 => "Asistente Social",
        304 => "Fisioterapeuta",
        305 => "Fonoaudiólogo",
        306 => "Esteticista",
        307 => "Nutricionista",
        308 => "Psicólogo",
        309 => "Quiroprata",
        310 => "Técnico em Enfermagem",
        311 => "Técnico em Saúde Bucal",
        312 => "Terapeuta Ocupacional",
        313 => "Veterinário"
      }
    }
  }

  def self.specialties
    str = []
    NAMES.each do |group|
      str << [ group[0], group.last[:specialty].collect{ |k, v| [v,k] } ]
    end
    str
  end

  # returns the profession id for a given specialty
  def self.group(specialty_id)
    hash_map = NAMES.map { |key, value| {key => value[:specialty].keys }}
    hash_map.find { |elem| elem[elem.keys.first].include?(specialty_id) }.keys[0]
  rescue
    nil
  end

  def self.council(specialty_id)
    if group_id = group(specialty_id)
      NAMES[group_id][:council]
    end
  end

  def self.name(specialty_id, plural = false)
    if group_id = group(specialty_id)
      plural ? NAMES[group_id][:name_plural] : NAMES[group_id][:name]
    end
  end

  def self.specialty(specialty_id)
    if group_id = group(specialty_id)
      NAMES[group_id][:specialty][specialty_id]
    end
  end
end
