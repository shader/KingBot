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

(deftem unit
  type      nil
  stone     nil
  wood      nil
  ore       nil
  pop       nil
  attack    nil
  def-inf   nil
  def-cav   nil
  def-bow   nil
  speed     nil
  cargo     nil)

(def init-kingbot ()
  (init-irc)
  (= kingbot-dir* "~/code/kingbot"
     kingbot-thread* nil
     kingbot-server* nil
     kingbot-channel* nil
     kingbot-nick* nil
     players* (table)
     setts* (table)
     missions* (table)
     units* (table)))

(def kingbot-load ()
  (load-units (+ kingbot-dir* "/units")))

(def load-units (d)
  (whilet u (dir d)
    (= (units* u) (temload 'unit (+ d u)))))

(def kingbot (server channel nick (o password nil))
  (irc-connect server nick password)
  (irc "JOIN " channel)
  (= kingbot-thread* 
       (thread (irc-loop kingbot-parse))
     kingbot-channel* channel
     kingbot-nick* nick
     kingbot-server* server))

(def restart-kingbot ()
  (with (c kingbot-channel*
	 n kingbot-nick*
	 s kingbot-server*)
    (aif irc-out* disconnect.it)
    (aif kingbot-thread* kill-thread.it)
    (load "~/code/kingbot/kingbot.arc")
    (kingbot s c n)))

;; (= templar      "(?i:templar|temp)s?"
;;    squire       "(?i:squire|sq|spear)s?"
;;    berserker    "(?i:berserker|zerk|berz|berk)s?"
;;    longbows     "(?i:long-?bow|LB)s?"
;;    spy          "(?i:spy|spies)"
;;    crusader     "(?i:crusader|sader|crus)s?"
;;    black-knight "(?i:black knight|bk)s?"
;;    ram          "(?i:battering ram|ram)s?"
;;    trebuchet    "(?i:trebuchet|treb)s?"
;;    count        "(?i:count|noble|snob)s?")

(def kingbot-parse (line)
  (aif (irc-parse line)
       (let (nick user host command chan msg) it
	 (if (re-match (string "(?i:" kingbot-nick* ")") chan)
	     (= chan nick))
	 (w/irc chan
	   (aif (headmatch "," msg)
		  (pr:on-err [string "Error: " (details _)] 
			   (fn () (tostring:write:eval:read:cut msg 1)))
		(re-match (string "(.*) o[fn] (.*) \\(([0-9]+)\\|([0-9]+)\\)"
				  ".*at ([0-9]+:[0-9]+:[0-9]+)") msg)
		  (let (m type name x y eta) it
		       (pr "Type: " type " Name: " name " X: " x " Y: " y " ETA: " eta))
                (re-match "(?i:distance.*?\\(?([0-9]+)\\|([0-9]+)\\)?.*?\\(?([0-9]+)\\|([0-9]+)\\)?)" msg)
		  (let (x1 y1 x2 y2) (map [coerce _ 'int] cdr.it)
		       (prf "The distance between ~a|~a and ~a|~a is ~a."
			    x1 y1 x2 y2 (distance x1 y1 x2 y2))))))))

(def distance (x1 y1 x2 y2)
  (nearest (sqrt (+ (expt (- x1 x2) 2) (expt (- y1 y2) 2)))
	      0.01))

(def ifmatch (s . xs)
  (map [aif (re-match car._ s) (cadr._ it)]
       pair.xs))