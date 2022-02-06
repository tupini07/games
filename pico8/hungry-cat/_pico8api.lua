function camera(x, y) end
function circ(x, y, r, col) end
function circfill(x, y, r, col) end
function oval(x0, y0, x1, y1, col) end
function ovalfill(x0, y0, x1, y1, col) end
function clip(x, y, w, h) end
function cls() end
function color(col) end
function cursor(x, y, col) end
function fget(n, f) end
function fillp(pat) end
function fset(n, f, v) end
function line(x0, y0, x1, y1, col) end
function pal(c0, c1, p) end
function palt(c, t) end
function pget(x, y) end
function print(str, x, y, col) end
function pset(x, y, c) end
function rect(x0, y0, x1, y1, col) end
function rectfill(x0, y0, x1, y1, col) end
function sget(x, y) end
function spr(n, x, y, w, h, flip_x, flip_y) end
function sset(x, y, c) end
function sspr(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y) end
function tline(x0, y0, x1, y1, mx, my, mdx, mdy) end
function add(t, v) end
function all(t) end
function count(t, v) end
function del(t, v) end
function deli(t, i) end
function foreach(t, f) end
function ipairs(t) end
function pairs(t) end
function next(t, key) end
function btn(i, p) end
function btnp(i, p) end
function music(n, fade_len, channel_mask) end
function sfx(n, channel, offset) end
function map(cel_x, cel_y, sx, sy, cel_w, cel_h, layer) end
function mget(x, y) end
function mset(x, y, v) end
function memcpy(dest_addr, source_addr, len) end
function memset(dest_addr, val, len) end
function peek(addr) end
function poke(addr, val) end
function abs(x) end
function atan2(dx, dy) end
function band(x, y) end
function bnot(x) end
function bor(x, y) end
function bxor(x, y) end
function ceil(x) end
function cos(x) end
function flr(x) end
function lshr(num, bits) end
function max(x, y) end
function mid(x, y, z) end
function min(x, y) end
function rnd(x) end
function rotl(num, bits) end
function rotr(num, bits) end
function sgn(x) end
function shl(x, y) end
function shr(x, y) end
function sin(x) end
function sqrt(x) end
function srand(x) end
function cartdata(id) end
function dget(index) end
function dset(index, value) end
function cstore(dest_addr, source_addr, len, filename) end
function reload(dest_addr, source_addr, len, filename) end
function cocreate(func) end
function coresume(cor, ...) end
function costatus(cor) end
function yield(...) end
function setmetatable(tbl, metatbl) end
function getmetatable(tbl) end
function type(v) end
function split(str, separator, convert_numbers) end
function sub(str, from, to) end
function chr(num) end
function ord(str, index) end
function tonum(str) end
function tostr(val, usehex) end
function time() end
function menuitem(index, label, callback) end
function extcmd(cmd) end
function assert(cond, message) end
function printh(str, filename, overwrite) end
function stat(n) end
function stop() end
function trace() end
