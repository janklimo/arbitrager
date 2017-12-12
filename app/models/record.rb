class Record < ApplicationRecord
  enum ticker: [ :eth, :btc, :xrp, :dash, :ltc ]
end
