(load "lib/irc.arc")

(deftem sett
  loc       nil
  name      nil
  owner     nil
  buildings nil
  troops    nil
  res       nil
  points    nil
  last-hit  nil)

(deftem player
  points    nil
  alliance  nil
  last-seen nil)

(deftem mission
  type      nil
  source    nil
  dest      nil
  arrival   nil
  troops    nil
  res       nil)

(= kingbot-thread* nil
   kingbot-channel* nil
   players* (table)
   setts* (table)
   missions* (table))

(def kingbot (server channel nick)
  (irc-connect server nick)
  (irc "JOIN " channel)
  (= kingbot-thread* (thread (irc-loop kingbot-parse)))
  (= kingbot-channel* channel))

(def kingbot-parse (line)
  (aif (irc-parse line)
       (let (nick user host command chan msg) it
         (aif (headmatch "," msg)
	        (irc-msg chan (on-err [string "Error: " (details _)] 
		  	              (fn () (tostring:write:eval:read:cut msg 1))))
	      (re-match (string "(.*) o[fn] (.*) \\(([0-9]+)\\|([0-9]+)\\).*at ([0-9]+:[0-9]+:[0-9]+)") msg)
	        (let (m type name x y eta) it
		  (irc-msg chan (string "Type: " type " Name: " name 
					" X: " x " Y: " y " ETA: " eta)))))))

(def mission (