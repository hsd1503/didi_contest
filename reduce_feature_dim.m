load('D:\projects\didi\final\basic_io\cache_new\concated_feats_table_1_dd_usernum.mat');

select_col = [160,34,35,161,191,319,162,325,4,163,312,156,184,50,209,48,46,494, ...
              483,112,210,452,313,155,320,490,154,3,486,42,198,283,208,493,431,2, ...
              165,326,193,192,1,497,5,422,277,211,284,175,206,36,7,436,45,207,314, ...
              437,239,178,321,363,453,168,355,393,492,242,362,205];
for i = 1:length(select_col)
    if select_col(i)==1
        select_col(i) = 2;
    else
        select_col(i) = select_col(i) + 2;
    end
end

select_col = [1,select_col];

concated_train_feats_table_1_dd_usernum_reduced = concated_train_feats_table_1_dd_usernum(:, select_col);
concated_val_feats_table_1_dd_usernum_reduced = concated_val_feats_table_1_dd_usernum(:, select_col)

all_concated_feats_reduced =  all_concated_train_feats_table_1(:, select_col);
concated_test_feats_table_1_reduced = concated_test_feats_table_1(:, select_col);