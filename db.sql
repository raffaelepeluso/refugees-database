drop table if exists ente cascade;
drop table if exists rifugiato cascade;
drop table if exists lingua cascade;
drop table if exists conoscenza cascade;
drop table if exists struttura_alloggiativa cascade;
drop table if exists progetto cascade;
drop table if exists edizione_progetto cascade;
drop table if exists corso cascade;
drop table if exists servizio cascade;
drop table if exists partecipazione cascade;
drop table if exists offerta cascade;
drop table if exists proposta cascade;
drop domain if exists dominioVulnerabilita cascade;

create domain dominioVulnerabilita as varchar(30)
default 'Nessuna vulnerabilita'
check (value in ('Disabilita', 'Donna in gravidanza', 'Minore non accompagnato', 'Nessuna vulnerabilita'));

create table ente(
	codice_fiscale varchar(11) primary key,
	denominazione varchar(60) not null,
	telefono varchar(13) not null,
	mail varchar(60) not null,
	nazione varchar(30) not null,
	citta varchar(30) not null
);

create table rifugiato(
	documento_identita varchar(9) primary key,
	nome varchar(100) not null,
	cognome varchar(100) not null,
	data_nascita date not null,
	sesso char(1) not null check(sesso = 'M' or sesso = 'F'),
	paese_provenienza varchar(30) not null,
	religione varchar(20) not null,
	titolo_studio varchar(100) default 'Nessun titolo',
	qualifica_professionale varchar(100) default 'Nessuna qualifica',
	vulnerabilita dominioVulnerabilita
);

create table lingua(
	nome varchar(30) primary key
);

create table conoscenza(
	lingua varchar(30) references lingua(nome) on update restrict on delete restrict,
	rifugiato varchar(10) references rifugiato(documento_identita) on update restrict on delete restrict deferrable initially deferred,
	primary key(lingua,rifugiato)
);

create table struttura_alloggiativa(
	cis varchar(19) primary key,
	nome varchar(100) not null,
	via varchar(200) not null,
	citta varchar(60) not null,
	capienza integer not  null,
	ospitalita_disabili boolean not null,
	mensa boolean not null
);

create table progetto(
	codice varchar(10) primary key,
	titolo varchar(50) not null,
	ambito varchar(50) not null,
	area_territoriale varchar(30) not null,
	tipologia varchar(30) not null check(tipologia = 'Ordinario' or tipologia = 'Vulnerabilita'),
	vulnerabilita dominioVulnerabilita,
	ente_assegnatario varchar(11) not null references ente(codice_fiscale) on update restrict on delete restrict,
	unique(titolo,ente_assegnatario)
);

create table edizione_progetto(
	codice varchar(12) primary key,
	progetto varchar(10) not null references progetto(codice) on update restrict on delete restrict,
	data_inizio date not null,
	data_fine date not null,
	numero_partecipanti integer not null,
	struttura varchar(19) not null references struttura_alloggiativa(cis) on update restrict on delete restrict,
	unique(data_inizio,progetto)
);

create table corso(
	codice varchar(10) primary key,
	descrizione varchar(500) not null,
	durata_ore integer not null,
	materia varchar(60) not null,
	qualifica_conseguita varchar(40) default 'Nessuna qualifica',
	rilascio_attestato boolean not null,
	luogo varchar(60) not null
);

create table servizio(
	codice varchar(10) primary key,
	tipologia varchar(50) not null,
	attivita varchar(100) not null,
	individuale boolean not null,
	luogo varchar(100) not  null
);

create table partecipazione(
	rifugiato varchar(10) references rifugiato(documento_identita) on update cascade on delete restrict,
	edizione_progetto varchar(12) references edizione_progetto(codice) on update restrict on delete restrict, 
	primary key(rifugiato, edizione_progetto)
);

create table offerta(
	servizio varchar(10) references servizio(codice) on update restrict on delete restrict, 
	edizione_progetto varchar(12) references edizione_progetto(codice) on update restrict on delete restrict deferrable initially deferred,
	primary key(servizio,edizione_progetto)
);

create table proposta(
	corso varchar(10) references corso(codice) on update restrict on delete restrict, 
	edizione_progetto varchar(12) references edizione_progetto(codice) on update restrict on delete restrict deferrable initially deferred,
	primary key(corso,edizione_progetto)
);

INSERT INTO ente(codice_fiscale, denominazione, telefono, mail, nazione, citta) VALUES
('80000330656', 'Comune di Salerno','089662134', 'comunedisalerno@gmail.com', 'Italia', 'Salerno'),
('80000330723', 'Associazione Arcobaleno','+393248612339', 'associazionearcobaleno@gmail.com', 'Italia', 'Milano'),
('80000456789', 'Restos du coeur','+333582367541', 'restosducoeur@gmail.com', 'Francia', 'Caen');

INSERT INTO lingua(nome) VALUES
('Italiano'),
('Francese'),
('Spagnolo'),
('Tedesco'),
('Arabo'),
('Ucraino'),
('Russo'),
('Inglese');

INSERT INTO conoscenza(lingua, rifugiato) VALUES
('Ucraino', 'IT3476889'),
('Inglese', 'IT3476889'),
('Russo', 'IT3476889'),
('Arabo', 'IT4512373'),
('Inglese', 'IT4512373'),
('Inglese', 'FR3256710'),
('Inglese', 'EN3265898');

INSERT INTO rifugiato(documento_identita, nome, cognome, data_nascita, sesso, paese_provenienza, religione, titolo_studio, vulnerabilita) VALUES
('IT3476889', 'Roman', 'Boyko', '12/05/1997', 'M', 'Ucraina', 'Cattolicesimo', 'Diploma', 'Disabilita'),
('EN3265898', 'Elizabeth', 'Swan', '18/05/1988', 'F', 'Inghilterra', 'Anglicanesimo','Diploma','Donna in gravidanza');
INSERT INTO rifugiato(documento_identita, nome, cognome, data_nascita, sesso, paese_provenienza, religione, vulnerabilita) VALUES
('IT4512373', 'Aisha', 'Ahmed', '13/01/2012', 'F', 'Siria', 'Islam', 'Minore non accompagnato');
INSERT INTO rifugiato(documento_identita, nome, cognome, data_nascita, sesso, paese_provenienza, religione) VALUES
('FR3256710', 'Alfatih', 'Ali', '14/08/1990', 'M', 'Sudan', 'Islam');

INSERT INTO struttura_alloggiativa(cis, nome, via, citta, capienza, ospitalita_disabili, mensa) VALUES
('SA675421312S0000032', 'Residence Mare', 'Via Dante Alighieri 72', 'Salerno', 40, true, true),
('MI345412111S0000067', 'Hotel Marconi', 'Via Marconi 2', 'Milano', 37, true, true),
('NO658966512S0000021', 'CPH Denoyez', 'Rue Denoyez 21', 'Caen', 60, false, false);

INSERT INTO progetto(codice, titolo, ambito, area_territoriale, tipologia, vulnerabilita, ente_assegnatario) VALUES
('EU0x123456', 'No limits', 'Sociale', 'Sud Italia', 'Vulnerabilita', 'Disabilita', '80000330656'),
('EU0x789568', 'Casa, mamma e bambino', 'Sociale', 'Nord Italia', 'Vulnerabilita', 'Donna in gravidanza', '80000330723'),
('EU0x762192', 'Bright future', 'Istruzione', 'Nord Italia', 'Vulnerabilita', 'Minore non accompagnato', '80000330723');

INSERT INTO progetto(codice, titolo, ambito, area_territoriale, tipologia, ente_assegnatario) VALUES
('EU0x540012', 'Restart', 'Lavorativo', 'Nord Francia', 'Ordinario', '80000456789');

INSERT INTO corso(codice, descrizione, durata_ore, materia, rilascio_attestato, luogo) VALUES
('EUcx547876', 'Corso di creatività artistica', 72, 'Arte', false, 'Associazione Art, Salerno'),
('EUcx349006', 'Corso di narrativa in inglese', 48, 'Inglese', true, 'IC Giovanni Paolo II, Salerno'),
('EUcx399016', 'Corso di italiano base', 72, 'Italiano', true, 'Scuola Galileo, Milano'),
('EUcx419071', 'Corso di matematica base', 72, 'Matematica', true, 'Scuola Galileo, Milano'),
('EUcx111397', 'Corso di francese base', 72, 'Francese', true, 'Institut Lemmonier, Caen'),
('EUcx824163', 'Corso sui diritti del lavoratore', 48, 'Cittadinanza', false, 'Institut Lemmonier, Caen'),
('EUcx550061', 'Corso preparto', 54, 'Sociale', false, 'Ospedale San Raffaele, Milano');

INSERT INTO corso(codice, descrizione, durata_ore, materia, qualifica_conseguita, rilascio_attestato, luogo) VALUES
('EUcx643210', 'Corso per operaio metalmeccanico', 200, 'Lavoro', 'Operaio base', true, 'Renault, Caen');

INSERT INTO servizio(codice, tipologia, attivita, individuale, luogo) VALUES
('EUsx547876', 'Sport', 'Pallacanestro in carrozzina', false, 'Asd Basket, Salerno'),
('EUsx349006', 'Assistenza', 'Seduta psicologica', true, 'Studio de Bellis, Angri'),
('EUsx399016', 'Sport', 'Varie attivita sportive', true, 'Centro sportivo, Pavia'),
('EUsx419071', 'Assistenza', 'Accoglienza in famiglia', false, 'Family first, Milano'),
('EUsx111397', 'Assistenza', 'Seduta psicologica', true, 'Scuola Galileo, Milano'),
('EUsx824163', 'Assistenza', 'Seduta psicologica', false, 'Anne Petite, Rouen'),
('EUsx550061', 'Assistenza', 'Inserimento lavorativo', false, 'Pole Employ, Caen'),
('EUsx643210', 'Assistenza', 'Assistenza legale per il lavoro', true, 'Cabinet pour le travail, Caen');

INSERT INTO proposta(corso, edizione_progetto) VALUES
('EUcx547876', 'EU0x123456.1'),
('EUcx349006', 'EU0x123456.1'),
('EUcx547876', 'EU0x123456.2'),
('EUcx399016', 'EU0x762192.1'),
('EUcx419071', 'EU0x762192.2'),
('EUcx111397', 'EU0x540012.1'),
('EUcx824163', 'EU0x540012.1'),
('EUcx550061', 'EU0x789568.1'),
('EUcx399016', 'EU0x789568.1'),
('EUcx643210', 'EU0x540012.2');

INSERT INTO offerta(servizio, edizione_progetto) VALUES
('EUsx547876', 'EU0x123456.2'),
('EUsx349006', 'EU0x123456.1'),
('EUsx349006', 'EU0x123456.2'),
('EUsx399016', 'EU0x762192.1'),
('EUsx419071', 'EU0x762192.1'),
('EUsx399016', 'EU0x762192.2'),
('EUsx111397', 'EU0x762192.2'),
('EUsx111397', 'EU0x789568.1'),
('EUsx824163', 'EU0x540012.1'),
('EUsx824163', 'EU0x540012.2'),
('EUsx550061', 'EU0x540012.1'),
('EUsx550061', 'EU0x540012.2'),
('EUsx643210', 'EU0x540012.2');

INSERT INTO edizione_progetto(codice, progetto, data_inizio, data_fine, numero_partecipanti, struttura) VALUES
('EU0x123456.1', 'EU0x123456', '12/01/2019', '12/03/2019', 1, 'SA675421312S0000032'),
('EU0x123456.2', 'EU0x123456', '20/04/2019', '20/06/2019', 1, 'SA675421312S0000032'),
('EU0x762192.1', 'EU0x762192', '15/09/2020', '31/12/2020', 1, 'MI345412111S0000067'),
('EU0x762192.2', 'EU0x762192', '18/01/2021', '18/05/2021', 1, 'MI345412111S0000067'),
('EU0x540012.1', 'EU0x540012', '01/01/2022', '20/03/2022', 1, 'NO658966512S0000021'),
('EU0x789568.1', 'EU0x789568', '25/03/2022', '28/06/2022', 1, 'MI345412111S0000067'),
('EU0x540012.2', 'EU0x540012', '10/04/2022', '10/06/2022', 1, 'NO658966512S0000021');

INSERT INTO partecipazione(rifugiato, edizione_progetto) VALUES
('IT3476889', 'EU0x123456.1'),
('EN3265898', 'EU0x789568.1'),
('IT3476889', 'EU0x123456.2'),
('IT4512373', 'EU0x762192.1'),
('IT4512373', 'EU0x762192.2'),
('FR3256710', 'EU0x540012.1'),
('FR3256710', 'EU0x540012.2');





















