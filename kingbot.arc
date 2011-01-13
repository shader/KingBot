
(= kingbot-thread* nil
   kingbot-channel* nil)

(def kingbot (server channel nick)
  (irc-connect server nick)
  (irc "JOIN " channel)
  (= kingbot-thread* (thread (irc-loop kingbot-parse)))
  (= kingbot-channel* channel))

(def kingbot-parse (line)
  (aif (irc-parse line)
       (let (nick user host command chan msg) it
         (if (headmatch "," msg)
	     (irc-msg chan (on-err [string "Error: " (details _)] 
				   (fn () (eval:read:cut msg 1))))
	     (headmatch "Attack" msg)
	     ()))))