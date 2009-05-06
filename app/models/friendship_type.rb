class FriendshipType < ActiveEnumeration::Base
  has_enumerated :requested, :translate_key => 'social.friendship_types.requested'
  has_enumerated :pending, :translate_key => 'social.friendship_types.pending'
  has_enumerated :accepted, :translate_key => 'social.friendship_types.accepted'
end
