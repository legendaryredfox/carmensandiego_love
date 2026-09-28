return {
    -- Tela inicial
    ["title.game_name"]           = "DETECTIVE AGENCY",
    ["title.press_any_key"]       = "PRESSIONE QUALQUER TECLA",
    ["title.subtitle"]            = "UM JOGO DE DETETIVE PELO MUNDO",
    ["title.copyright"]           = "(C) {year} - LEGENDARYREDFOX",

    -- Seleção de idioma
    ["language.choose"]           = "ESCOLHA SEU IDIOMA",
    ["language.en"]               = "INGLES",
    ["language.pt"]               = "PORTUGUES",
    ["language.nav_hint"]         = "CIMA/BAIXO  ENTER",

    -- Menu principal
    ["menu.new_game"]             = "NOVO JOGO",
    ["menu.continue"]             = "CONTINUAR",
    ["menu.leaderboard"]          = "PLACAR",
    ["menu.settings"]             = "OPCOES",
    ["menu.quit"]                 = "SAIR",

    -- Opções
    ["settings.title"]            = "OPCOES",
    ["settings.language"]         = "IDIOMA",
    ["settings.music_volume"]     = "VOLUME DA MUSICA",
    ["settings.sfx_volume"]       = "VOLUME DOS EFEITOS",
    ["settings.typewriter_speed"] = "VELOCIDADE DO TEXTO",
    ["settings.nav_hint"]         = "CIMA/BAIXO  ESQ/DIR  ENTER  ESC=VOLTAR",

    -- Nome do detetive
    ["name.title"]                = "SEDE DA INTERPOL",
    ["name.prompt"]               = "INSIRA SEU NOME, DETETIVE:",
    ["name.confirm"]              = "PRESSIONE ENTER PARA CONFIRMAR",

    -- Briefing
    ["briefing.title"]            = "*** DESPACHO DA INTERPOL ***",
    ["briefing.stolen"]           = "{item} foi roubado(a) de {city}.",
    -- "pessoa suspeita" avoids the masculine default of "um suspeito",
    -- which would misleadingly hint at the thief's sex before any clue does
    ["briefing.suspect_seen"]     = "Uma pessoa suspeita foi vista fugindo da cena.",
    ["briefing.mission"]          = "Sua missao: rastrear o ladrao\ne efetuar a prisao.\nVoce tem {days} dias.",
    ["briefing.good_luck"]        = "Boa sorte, {rank} {name}.",
    ["briefing.press_any_key"]    = "[ PRESSIONE QUALQUER TECLA ]",

    -- Cidade
    ["city.interpol"]             = "COMPUTADOR DO CRIME",
    ["city.airport"]              = "AEROPORTO",
    ["city.status_city"]          = "CIDADE: {city}",
    ["city.status_days"]          = "DIAS RESTANTES: {days}",
    ["city.status_rank"]          = "PATENTE: {rank}",
    ["city.nav_hint"]             = "[ SETAS  ENTER ]",

    -- Local de investigacao
    ["venue.nobody_suspicious"]   = "Nenhum suspeito foi visto aqui.",
    ["venue.witness_says"]        = "Uma testemunha relata:",
    ["venue.clue_destination"]    = "O informante mencionou {hint}.",
    ["venue.clue_trait"]          = "O suspeito foi descrito como {trait}.",
    ["venue.back"]                = "VOLTAR",

    -- Nomes de locais (derivados da categoria da pista naquele local)
    ["venue_name.landmark.1"]     = "MUSEU",
    ["venue_name.landmark.2"]     = "RUINAS ANTIGAS",
    ["venue_name.landmark.3"]     = "PRACA DO MONUMENTO",
    ["venue_name.currency.1"]     = "CASA DE CAMBIO",
    ["venue_name.currency.2"]     = "BANCO CENTRAL",
    ["venue_name.currency.3"]     = "BARRACAS DO MERCADO",
    ["venue_name.language.1"]     = "INSTITUTO DE IDIOMAS",
    ["venue_name.language.2"]     = "SEBO ANTIGO",
    ["venue_name.language.3"]     = "ESCRITORIO DE TRADUCAO",
    ["venue_name.geography.1"]    = "OBSERVATORIO",
    ["venue_name.geography.2"]    = "POSTO DE TURISMO",
    ["venue_name.geography.3"]    = "MIRANTE",
    ["venue_name.wildlife.1"]     = "RESERVA NATURAL",
    ["venue_name.wildlife.2"]     = "ZOOLOGICO",
    ["venue_name.wildlife.3"]     = "SANTUARIO DE FAUNA",
    ["venue_name.culture.1"]      = "CENTRO CULTURAL",
    ["venue_name.culture.2"]      = "GRANDE TEATRO",
    ["venue_name.culture.3"]      = "GALERIA DE ARTE",
    ["venue_name.industry.1"]     = "ESCRITORIO DE COMERCIO",
    ["venue_name.industry.2"]     = "ARMAZEM DO PORTO",
    ["venue_name.industry.3"]     = "DISTRITO INDUSTRIAL",
    ["venue_name.trait.1"]        = "TAVERNA DO INFORMANTE",
    ["venue_name.trait.2"]        = "CONTATO DO BECO",
    ["venue_name.trait.3"]        = "ESQUINA DA TESTEMUNHA",
    ["venue_name.terminal.1"]     = "ESCONDERIJO SUSPEITO",
    ["venue_name.terminal.2"]     = "RUA TRANQUILA",
    ["venue_name.generic.1"]      = "DELEGACIA LOCAL",

    -- Transicao de investigacao (indo do centro da cidade ate o local)
    ["investigating.heading_over"] = "A CAMINHO...",

    -- Computador do crime
    ["crime.title"]               = "COMPUTADOR DO CRIME - INTERPOL",
    ["crime.sex"]                 = "SEXO",
    ["crime.hair"]                = "CABELO",
    ["crime.hobby"]               = "HOBBY",
    ["crime.vehicle"]             = "VEICULO",
    ["crime.feature"]             = "SINAL",
    ["crime.food"]                = "PREFERENCIA ALIMENTAR",
    ["crime.search"]              = "BUSCAR",
    ["crime.issue_warrant"]       = "EMITIR MANDADO",
    ["crime.no_match"]            = "NENHUM SUSPEITO COINCIDE. REVISE AS PISTAS.",
    ["crime.multiple_match"]      = "VARIOS SUSPEITOS COINCIDEM. COLETE MAIS PISTAS.",
    ["crime.warrant_issued"]      = "MANDADO DE PRISAO EMITIDO PARA {name}.",
    ["crime.suspects_label"]      = "SUSPEITOS: {count}",
    ["crime.warrant_label"]       = "MANDADO: {name}",
    ["crime.nav_hint"]            = "CIMA/BAIXO  ESQ/DIR  S=BUSCAR  W=MANDADO  ESC=VOLTAR",

    -- Viagem
    ["travel.title"]              = "SALA DE EMBARQUE",
    ["travel.select"]             = "SELECIONE O DESTINO:",
    ["travel.distance"]           = "{km} KM",
    ["travel.duration"]           = "VOO DE {hours}H",
    ["travel.departing"]          = "PARTINDO PARA {city}...",
    ["travel.low_on_time"]        = "AVISO: POUCO TEMPO RESTANTE!",
    ["travel.nav_hint"]           = "CIMA/BAIXO  ENTER=PARTIR  ESC=VOLTAR",

    -- Prisao
    ["arrest.success"]            = "Voce prendeu {name}!\nCaso encerrado.",
    ["arrest.wrong_warrant"]      = "Suspeito errado!\n{name} escapou.",
    ["arrest.no_warrant"]         = "Sem mandado.\nO suspeito escapou.",
    ["arrest.wrong_city"]         = "O ladrao nao esta aqui.",
    ["arrest.title_success"]      = "CASO ENCERRADO!",
    ["arrest.title_failed"]       = "MISSAO FRACASSADA",
    ["arrest.next_mission"]       = "[ PRESSIONE ENTER PARA A PROXIMA MISSAO ]",
    ["arrest.continue"]           = "[ PRESSIONE ENTER PARA CONTINUAR ]",

    -- Promocao
    ["rankup.title"]              = "PROMOCAO!",
    ["rankup.message"]            = "Parabens, {name}.\nVoce agora e {rank}.",
    ["rankup.press_enter"]        = "[ PRESSIONE ENTER ]",

    -- Game over
    ["gameover.title"]            = "MISSAO FRACASSADA",
    ["gameover.time"]             = "Voce ficou sem tempo.\nO ladrao escapou.",
    ["gameover.retry"]            = "PRESSIONE ENTER PARA TENTAR NOVAMENTE",

    -- Hall da Fama (prisao final da lider da organizacao)
    ["hallfame.title"]            = "HALL DA FAMA",
    ["hallfame.message"]          = "Voce prendeu {leader} e desmantelou a\norganizacao de vez, {rank} {name}.\n\nSua carreira como detetive esta completa.",
    ["hallfame.continue"]         = "[ PRESSIONE ENTER PARA VOLTAR AO MENU ]",

    -- Placar
    ["leaderboard.title"]         = "MELHORES DETETIVES",
    ["leaderboard.empty"]         = "NENHUM REGISTRO AINDA.",
    ["leaderboard.back"]          = "PRESSIONE ESC PARA VOLTAR",
    ["leaderboard.col_num"]       = "#",
    ["leaderboard.col_name"]      = "NOME",
    ["leaderboard.col_rank"]      = "PATENTE",
    ["leaderboard.col_cases"]     = "CASOS",
    ["leaderboard.col_score"]     = "PONTOS",

    -- Patentes
    ["rank.rookie"]               = "Novato",
    ["rank.sleuth"]               = "Investigador",
    ["rank.private_eye"]          = "Detetive Particular",
    ["rank.investigator"]         = "Investigador Senior",
    ["rank.ace_detective"]        = "Detetive As",

    -- Tracos dos suspeitos
    ["trait.sex.male"]            = "Masculino",
    ["trait.sex.female"]          = "Feminino",
    ["trait.hair.brown"]          = "Cabelo castanho",
    ["trait.hair.blonde"]         = "Cabelo loiro",
    ["trait.hair.red"]            = "Cabelo ruivo",
    ["trait.hair.black"]          = "Cabelo preto",
    ["trait.hobby.tennis"]        = "Joga tenis",
    ["trait.hobby.mountain_climbing"] = "Alpinista",
    ["trait.hobby.croquet"]       = "Joga croquete",
    ["trait.hobby.skydiving"]     = "Pratica paraquedismo",
    ["trait.hobby.swimming"]      = "Pratica natacao",
    ["trait.vehicle.convertible"] = "Dirige um conversivel",
    ["trait.vehicle.limousine"]   = "Viaja de limusine",
    ["trait.vehicle.motorcycle"]  = "Anda de moto",
    ["trait.vehicle.racecar"]     = "Dirige um carro de corrida",
    ["trait.feature.tattoo"]      = "Tem uma tatuagem",
    ["trait.feature.ring"]        = "Usa um anel distintivo",
    ["trait.feature.jewelry"]     = "Usa joias chamativas",
    ["trait.feature.scar"]        = "Tem uma cicatriz evidente",
    ["trait.food.mexican"]        = "Prefere comida mexicana",
    ["trait.food.seafood"]        = "Prefere frutos do mar",

    -- Hora / barra de status
    ["status.time"]               = "HORA: {time}",
    ["status.deadline"]           = "PRAZO: {time}",
    ["briefing.deadline"]         = "PRENDA O SUSPEITO ATÉ {deadline}.",

    -- Pistas genéricas
    ["clue.generic.destination"]  = "atividade incomum em uma terra distante",
    ["clue.terminal"]             = "Nada suspeito aqui.",

    -- Itens roubados — itens de marco historico ligados a sua cidade real
    -- (ver ITEM_BY_CITY em src/mission.lua); os genericos servem pra qualquer cidade
    ["item.mona_lisa"]            = "A Mona Lisa",
    ["item.crown_jewels"]         = "As Joias da Coroa",
    ["item.magna_carta"]          = "A Magna Carta",
    ["item.aztec_calendar"]       = "A Pedra do Calendario Asteca",
    ["item.parthenon_frieze"]     = "Um Friso do Partenon",
    ["item.eiffel_torch"]         = "A Tocha da Torre Eiffel",
    ["item.colosseum_stone"]      = "Uma Pedra do Coliseu",
    ["item.big_ben_bell"]         = "O Sino do Big Ben",
    ["item.generic_painting"]     = "Uma pintura inestimavel",
    ["item.generic_gem"]          = "Uma gema rara",
    ["item.generic_relic"]        = "Uma relíquia antiga",
    ["item.generic_document"]     = "Um documento historico",
    ["item.generic_statue"]       = "Uma estatua de museu",

    -- Informacoes da cidade ao chegar
    ["city_info.press_enter"]     = "PRESSIONE ENTER PARA CONTINUAR",
    ["city_info.athens"]          = "CAPITAL DA GRECIA, LAR DA ANTIGA ACROPOLE E DO PARTENON.",
    ["city_info.baghdad"]         = "CAPITAL DO IRAQUE, AS MARGENS DO RIO TIGRE.",
    ["city_info.bamako"]          = "CAPITAL DO MALI, AS MARGENS DO RIO NIGER, CONHECIDA POR SUA CENA MUSICAL.",
    ["city_info.bangkok"]         = "CAPITAL DA TAILANDIA, FAMOSA POR TEMPLOS ORNAMENTADOS E O GRANDE PALACIO.",
    ["city_info.beijing"]         = "CAPITAL DA CHINA, LAR DA CIDADE PROIBIDA E PROXIMA A GRANDE MURALHA.",
    ["city_info.budapest"]        = "CAPITAL DA HUNGRIA, DIVIDIDA PELO DANUBIO EM BUDA E PEST, FAMOSA POR SEUS BANHOS TERMAIS.",
    ["city_info.buenos_aires"]    = "CAPITAL DA ARGENTINA, BERCO DO TANGO.",
    ["city_info.cairo"]           = "CAPITAL DO EGITO, AS MARGENS DO RIO NILO, PERTO DAS PIRAMIDES DE GIZA.",
    ["city_info.colombo"]         = "MAIOR CIDADE E PRINCIPAL PORTO DO SRI LANKA, HISTORICO CENTRO DO COMERCIO DE ESPECIARIAS E CHA.",
    ["city_info.istanbul"]        = "MAIOR CIDADE DA TURQUIA, ENTRE A EUROPA E A ASIA, ATRAVESSADA PELO BOSFORO.",
    ["city_info.kathmandu"]       = "CAPITAL DO NEPAL, PORTA DE ENTRADA PARA O HIMALAIA.",
    ["city_info.kigali"]          = "CAPITAL DE RUANDA, CONSTRUIDA SOBRE COLINAS, CONHECIDA POR SUA LIMPEZA.",
    ["city_info.lima"]            = "CAPITAL DO PERU, CIDADE COSTEIRA COM UM CENTRO COLONIAL BEM PRESERVADO.",
    ["city_info.london"]          = "CAPITAL DO REINO UNIDO, AS MARGENS DO TAMISA, LAR DO BIG BEN.",
    ["city_info.mexico_city"]     = "CAPITAL DO MEXICO, CONSTRUIDA SOBRE A ANTIGA CAPITAL ASTECA TENOCHTITLAN.",
    ["city_info.montreal"]        = "SEGUNDA MAIOR CIDADE DO CANADA, POLO FRANCOFONO NUMA ILHA DO RIO SAO LOURENCO.",
    ["city_info.moroni"]          = "CAPITAL DAS COMORES, ILHA VULCANICA CONHECIDA POR BAUNILHA E YLANG-YLANG.",
    ["city_info.moscow"]          = "CAPITAL DA RUSSIA, LAR DO KREMLIN E DA PRACA VERMELHA.",
    ["city_info.new_delhi"]       = "CAPITAL DA INDIA, LAR DO PORTAO DA INDIA E VIZINHA DA HISTORICA VELHA DELHI.",
    ["city_info.new_york"]        = "MAIOR CIDADE DOS ESTADOS UNIDOS, LAR DA ESTATUA DA LIBERDADE E DE WALL STREET.",
    ["city_info.oslo"]            = "CAPITAL DA NORUEGA, SITUADA NO FIM DE UM LONGO FIORDE.",
    ["city_info.paris"]           = "CAPITAL DA FRANCA, LAR DA TORRE EIFFEL AS MARGENS DO SENA.",
    ["city_info.port_moresby"]    = "CAPITAL DA PAPUA-NOVA GUINE, NO LITORAL DO MAR DE CORAL.",
    ["city_info.reykjavik"]       = "CAPITAL DA ISLANDIA, A CAPITAL NACIONAL MAIS AO NORTE DO MUNDO.",
    ["city_info.rio_de_janeiro"]  = "FAMOSA CIDADE LITORANEA DO BRASIL, LAR DO CRISTO REDENTOR.",
    ["city_info.rome"]            = "CAPITAL DA ITALIA, LAR DO ANTIGO COLISEU E DO ENCLAVE DO VATICANO.",
    ["city_info.san_marino"]      = "UMA DAS REPUBLICAS MAIS ANTIGAS DO MUNDO, MICROESTADO NO TOPO DE UMA MONTANHA CERCADO PELA ITALIA.",
    ["city_info.singapore"]       = "CIDADE-ESTADO INSULAR E GRANDE POLO PORTUARIO DO SUDESTE ASIATICO.",
    ["city_info.sydney"]          = "MAIOR CIDADE DA AUSTRALIA, CONHECIDA POR SUA OPERA E PELA PONTE DA BAIA.",
    ["city_info.tokyo"]           = "CAPITAL DO JAPAO, UMA DAS AREAS METROPOLITANAS MAIS POPULOSAS DO MUNDO.",
}
