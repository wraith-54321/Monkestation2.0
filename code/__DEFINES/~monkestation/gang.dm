#define GANG_RANK_MEMBER 0
#define GANG_RANK_LIEUTENANT 1
#define GANG_RANK_BOSS 2

///Checks if a gangmember antag datum's rank is >= the input gang rank level
#define MEETS_GANG_RANK (antag_datum, rank_to_meet) antag_datum?.rank >= rank_to_meet
