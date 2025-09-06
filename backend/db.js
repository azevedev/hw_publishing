
const { createClient } = require("@supabase/supabase-js");
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();
console.log("Supabase URL:", process.env.SUPABASE_URL);
console.log("Supabase Key:", process.env.SUPABASE_KEY);
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = { supabase };
        