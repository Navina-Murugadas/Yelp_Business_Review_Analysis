CREATE OR REPLACE TABLE stopwords (
    word STRING
);

-- Insert comprehensive stopword list
INSERT INTO stopwords (word) VALUES 
-- Common English stopwords
('a'), ('about'), ('above'), ('after'), ('again'), ('against'), 
('all'), ('am'), ('an'), ('and'), ('any'), ('are'), ('as'), ('at'), 
('be'), ('because'), ('been'), ('before'), ('being'), ('below'), 
('between'), ('both'), ('but'), ('by'), ('could'), ('did'), ('do'), 
('does'), ('doing'), ('down'), ('during'), ('each'), ('few'), 
('for'), ('from'), ('further'), ('had'), ('has'), ('have'), ('having'), 
('he'), ('her'), ('here'), ('hers'), ('herself'), ('him'), ('himself'), 
('his'), ('how'), ('i'), ('if'), ('in'), ('into'), ('is'), ('it'), 
('its'), ('itself'), ('let'), ('me'), ('more'), ('most'), ('my'), 
('myself'), ('nor'), ('not'), ('of'), ('off'), ('on'), ('once'), 
('only'), ('or'), ('other'), ('ought'), ('our'), ('ours'), ('ourselves'), 
('out'), ('over'), ('own'), ('same'), ('she'), ('should'), ('so'), 
('some'), ('such'), ('than'), ('that'), ('the'), ('their'), ('theirs'), 
('them'), ('themselves'), ('then'), ('there'), ('these'), ('they'), 
('this'), ('those'), ('through'), ('to'), ('too'), ('under'), ('until'), 
('up'), ('very'), ('was'), ('we'), ('were'), ('what'), ('when'), 
('where'), ('which'), ('while'), ('who'), ('whom'), ('why'), ('with'), 
('would'), ('you'), ('your'), ('yours'), ('yourself'), ('yourselves'),

-- Custom: common review filler terms
('get'), ('just'), ('first'), ('even'), ('also'), ('always'), ('no'),
('back'), ('much'), ('come'), ('now'), ('minutes'), ('after'), 
('still'), ('put'), ('go'), ('because'), ('ever'), ('really'), 
('im'), ('ive'), ('dont'), ('didnt'), ('cant'), ('couldnt'), 
('wasnt'), ('havent'), ('hasnt'), ('wont'), ('youre'), ('youve'), 
('its'), ('isnt'), ('arent'), ('doesnt'), ('do'), ('definitely'),
('actually'), ('came'), ('make'), ('take'), ('took'), ('told'), ('try'),
('say'), ('said'), ('see'), ('know'), ('made'), ('used'), ('wait'), ('want'), ('wants'),
('want to'), ('time'), ('times'), ('anytime'), ('another'), ('sure'), ('enough'),
('many'), ('got'), ('tried'), ('think'), ('day'), ('year'), ('years'), ('last'),
('never'), ('since'), ('every'), ('someone'), ('something'), ('wherever'), ('must'),
('will'), ('asked'), ('us'), ('around'), ('give'), ('went'), ('next'), ('everything'),
('can'), ('going'), ('little'), ('small'), ('right'), ('find'), ('lot'), ('bit'),

-- Single letter noise or numerics
('g'), ('nt'), ('ll'), ('re'), ('one'), ('two'), 
('0'), ('1'), ('2'), ('3'), ('4'), ('5');


SELECT *
FROM stopwords

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE word_frequencies AS
WITH words AS (
  SELECT 
    LOWER(TRIM(word.value)) AS word
  FROM tbl_yelpreviews,
       LATERAL FLATTEN(
         input => SPLIT(
           REGEXP_REPLACE(review_text, '[^a-zA-Z ]', ''), ' '
         )
       ) word
)
SELECT w.word, COUNT(*) AS frequency
FROM words w
LEFT JOIN stopwords sw ON w.word = sw.word
WHERE sw.word IS NULL AND w.word != ''
GROUP BY w.word
HAVING COUNT(*) >= 100000
ORDER BY frequency DESC;

------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE word_frequencies_dynamic_normalized AS
WITH flattened_reviews AS (
    SELECT 
        bu.city,
        TRIM(cat.value) AS category,
        LOWER(TRIM(w.value)) AS word
    FROM tbl_yelpbusinesses bu
    JOIN tbl_yelpreviews re 
        ON re.business_id = bu.business_id
    JOIN LATERAL SPLIT_TO_TABLE(bu.categories, ',') AS cat
    JOIN LATERAL FLATTEN(
        input => SPLIT(
            REGEXP_REPLACE(re.review_text, '[^a-zA-Z ]', ''), ' ')
    ) AS w
),
cleaned AS (
    SELECT 
        fr.city, 
        fr.category, 
        fr.word
    FROM flattened_reviews fr
    LEFT JOIN stopwords s 
        ON fr.word = s.word
    WHERE s.word IS NULL 
      AND fr.word != ''
)
SELECT 
    city, 
    category, 
    word, 
    COUNT(*) AS frequency
FROM cleaned
GROUP BY city, category, word
HAVING COUNT(*) >= 100
ORDER BY frequency DESC;

------------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM WORD_FREQUENCIES


SELECT *
FROM word_frequencies_dynamic_normalized

