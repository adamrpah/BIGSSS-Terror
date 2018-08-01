using CSV, DataFrames

input_file  = ARGS[1]
output_file = ARGS[2]

input_df = CSV.read(input_file, header = 7, rows_for_type_detect = 1000)
input_df[:country] = input_df[Symbol("input-folder")] # rename column

output_df = by(input_df, [:country, :alpha, :beta, :omega]) do df
  DataFrame(completed = sum(df[Symbol("[step]")] .== 1826), total = length(df))
end

CSV.write(output_file, output_df)
