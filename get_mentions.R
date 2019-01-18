library(magrittr)


token <- rtweet::create_token(
  app = "Tech influensers",
  consumer_key = consumer_key, consumer_secret = consumer_secret,
  access_token = access_token, access_secret = access_secret
)

id_esp <- "1084128514218041345"
id_eng <- "1084130110691774471"

mentions <- rtweet::get_mentions(n=500, since_id = id_esp, token = token,
                                 tweet_mode = "extended", include_entities = T)
tibble::glimpse(mentions)

tweets_mentions <- rtweet::lookup_statuses(mentions$status_id) %>%
  dplyr::filter(is_retweet == FALSE) %>%
  dplyr::select(user_id, status_id, screen_name, text, reply_to_screen_name,
                mentions_user_id, mentions_screen_name) %>%
  tidyr::separate_rows(mentions_screen_name, sep = '[^[a-zA-Z0-9_].]+') %>%
  dplyr::filter(!(mentions_screen_name %in% c('c',""))) %>%
  dplyr::filter(reply_to_screen_name != mentions_screen_name)

tibble::glimpse(tweets_mentions)

handles <- tweets_mentions %>%
  dplyr::distinct(tweets_mentions$mentions_screen_name)

users <- rtweet::lookup_users(handles$`tweets_mentions$mentions_screen_name`,
                              token = token) %>%
  dplyr::select(screen_name, name, location, description,
                profile_expanded_url, profile_image_url)

communities <- c('cylicon_valley', 'GDGValladolid', 'os_weekends', 'DevWomen_ES',
                 'codecoolture', 'comunidadcode', 'MLHispano', 'PillarsJS',
                 'MadridGUG', 'wtmbcn', 'Lambda_World', 'AngularGirls',
                 'GDG_Menorca', 'frontfest', 'wecodefest', 'geekandtechgirl',
                 'PyLadiesMadrid', 'MakespaceMadrid', 'GDGToledo_es', 'commitconf',
                 'devscola', 'AdaLab_Digital')
meetup_url <- 'meetup.com'
users %<>%
  dplyr::mutate(who_is = ifelse(
    screen_name %in% communities,
    "community",
    "person"
  ))

users %<>%
  dplyr::right_join(readr::read_csv('handle.csv'))

readr::write_csv(users, 'community_slides_files/community_people.csv')
